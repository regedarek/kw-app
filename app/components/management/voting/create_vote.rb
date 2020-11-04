module Management
  module Voting
    class CreateVote
      include Dry::Monads::Either::Mixin

      def initialize(form)
        @form = form
      end

      def call(raw_inputs:)
        form_outputs = form.call(raw_inputs.to_unsafe_h)
        return Left(raw_inputs[:case_id]) unless form_outputs.success?

        case_record = Management::Voting::CaseRecord.find_by(id: raw_inputs[:case_id])
        return Left(raw_inputs[:case_id]) unless case_record.voting?

        if Management::Voting::CommissionRecord.exists?(authorized_id: form_outputs[:user_id])
          Management::Voting::VoteRecord.create(form_outputs.to_h)

          commissions = Management::Voting::CommissionRecord.where(authorized_id: form_outputs[:user_id]).each do |commission|
            Management::Voting::VoteRecord.create(form_outputs.to_h.merge(user_id: commission.owner_id, commission: true, authorized_id: form_outputs[:user_id]))
          end

          Right(raw_inputs[:case_id])
        else
          vote_record = Management::Voting::VoteRecord.new(form_outputs.to_h)

          if vote_record.save
            Right(vote_record.case_id)
          else
            Left(raw_inputs[:case_id])
          end
        end
      end

      private

      attr_reader :form
    end
  end
end

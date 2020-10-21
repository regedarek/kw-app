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

        vote_record = Management::Voting::VoteRecord.new(form_outputs.to_h)
        if vote_record.save
          Right(vote_record.case_id)
        else
          Left(raw_inputs[:case_id])
        end
      end

      private

      attr_reader :form
    end
  end
end

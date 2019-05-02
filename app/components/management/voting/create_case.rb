module Management
  module Voting
    class CreateCase
      include Dry::Monads::Either::Mixin

      def initialize(form)
        @form = form
      end

      def call(raw_inputs:)
        form_outputs = form.call(raw_inputs.to_unsafe_h)
        return Left(form_outputs.messages.values) unless form_outputs.success?

        case_record = Management::Voting::CaseRecord.create(form_outputs.to_h)

        Management::Voting::Repository.new.management_users.each do |user|
          Management::Voting::Mailer.notify(case_record.id, user.id).deliver_later
        end

        Right(:success)
      end

      private

      attr_reader :form
    end
  end
end

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
        if case_record.hide_votes?
          case_record.finish!
        end

        Management::Voting::Repository.new.management_users.each do |user|
          NotificationCenter::NotificationRecord.create(
            recipient_id: user.id,
            actor_id: case_record.creator_id,
            action: 'created_voting',
            notifiable_id: case_record.id,
            notifiable_type: 'Management::Voting::CaseRecord'
          )
          Management::Voting::Mailer.notify(case_record.id, user.id).deliver_later
        end unless case_record.hide_votes?

        Right(:success)
      end

      private

      attr_reader :form
    end
  end
end

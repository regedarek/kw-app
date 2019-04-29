module EmailCenter
  module Api
    class EmailsController < ApplicationController
      protect_from_forgery with: :null_session
      skip_before_action  :verify_authenticity_token

      def delivered
        message_id = params.to_unsafe_h.dig("event-data","message","headers","message-id")
        email = EmailCenter::EmailRecord.find_by(message_id: message_id)

        if email
          return head :not_acceptable if email.delivered?

          email.deliver!
          email.update(delivered_at: Time.current)

          head :ok
        else
          head :not_found
        end
      end
    end
  end
end

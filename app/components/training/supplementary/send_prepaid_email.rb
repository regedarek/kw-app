module Training
  module Supplementary
    class SendPrepaidEmail
      def send_prepaid_emails
        prepaid_emails.each do |sign_up|
          Training::Supplementary::SignUpMailer.prepaid_email(sign_up.id).deliver_later
          sign_up.update(paid_email_sent_at: Time.now)
        end
      end

      private

      def prepaid_emails
        Training::Supplementary::Repository.new.prepaid_not_emailed_sign_ups
      end
    end
  end
end

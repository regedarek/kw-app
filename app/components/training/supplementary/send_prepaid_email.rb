module Training
  module Supplementary
    class SendPrepaidEmail
      def send_prepaid_emails
        prepaid_emails.map(&:id).each do |sign_up_id|
          Training::Supplementary::Workers::SendPrepaidEmailsWorker.perform_async(sign_up_id)
        end
      end

      private

      def prepaid_emails
        Training::Supplementary::Repository.new.prepaid_not_emailed_sign_ups
      end
    end
  end
end

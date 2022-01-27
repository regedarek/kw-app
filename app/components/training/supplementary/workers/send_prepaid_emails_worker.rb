module Training
  module Supplementary
    module Workers
      class SendPrepaidEmailsWorker
        include Sidekiq::Worker

        def perform(sign_up_id)
          sign_up = Training::Supplementary::SignUpRecord.find(sign_up_id)
          return true if sign_up.course.send_manually?

          Training::Supplementary::SignUpMailer.prepaid_email(sign_up.id).deliver_later
          sign_up.update(paid_email_sent_at: Time.zone.now)
        end
      end
    end
  end
end


module Business
  module Workers
    class SendListWorker
      include Sidekiq::Worker

      def perform(sign_up_id)
        sign_up = Business::SignUpRecord.find(sign_up_id)
        ::Business::SignUpMailer.list(sign_up_id).deliver_later
        sign_up.update(equipment_at: Time.zone.now)
      end
    end
  end
end

module Business
  module Workers
    class DestroyExpiredSignUpWorker
      include Sidekiq::Worker

      def perform(sign_up_id)
        sign_up = ::Business::SignUpRecord.find(sign_up_id)
        Payments::DeletePayment.new(payment: sign_up.payment).delete if sign_up.payment && sign_up.payment.payment_url
        PaperTrail.request(whodunnit: sign_up.name) do
          sign_up.course.update(seats: sign_up.course.seats - 1)
        end
        sign_up.destroy
      end
    end
  end
end

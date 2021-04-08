module Business
  module Workers
    class DestroyExpiredSignUpWorker
      include Sidekiq::Worker

      def perform(sign_up_id)
        sign_up = ::Business::SignUpRecord.find(sign_up_id)
        Payments::DeletePayment.new(payment: sign_up.first_payment).delete if sign_up.first_payment && sign_up.first_payment.payment_url
        PaperTrail.request(whodunnit: sign_up.name) do
          sign_up.course.update(seats: sign_up.course.seats - 1)
        end

        email = sign_up.email
        course = sign_up.course

        sign_up.destroy

        ::Business::SignUpMailer.deleted_sign_up(course, email).deliver_later
      end
    end
  end
end

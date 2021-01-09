module UserManagement
  module Workers
    class ProfileRecalculateCostWorker
      include Sidekiq::Worker

      def perform(profile_id)
        profile = Db::Profile.find(profile_id)
        profile.update_column(
          :cost, ::UserManagement::ApplicationCost.for(profile: profile).sum
        )
        payment = profile.payment
        if payment
          params = ::Payments::Dotpay::AdaptPayment.new(payment: payment).to_params
          payment_request = ::Payments::Dotpay::PaymentRequest.new(params: params, type: :fees).execute
          payment_request.success do |payment_url:|
            payment.update(payment_url: payment_url)
          end
        end
      end
    end
  end
end

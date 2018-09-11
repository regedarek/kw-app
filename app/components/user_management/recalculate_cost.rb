module UserManagement
  class RecalculateCost
    def all
      Db::Profile.includes(:payment).where(accepted: false, payments: { state: 'unpaid' }).each do |profile|
        profile.update_column(
          :cost, UserManagement::ApplicationCost.for(profile: profile).sum
        )
        payment = profile.payment
        if payment
          params = Payments::Dotpay::AdaptPayment.new(payment: payment).to_params
          payment_request = Payments::Dotpay::PaymentRequest.new(params: params, type: :fees).execute
          payment_request.success do |payment_url:|
            payment.update(payment_url: payment_url)

            Net::HTTP.get(URI('https://hc-ping.com/d5a75af7-f362-4595-a736-4df5e8169aaf'))
          end
        end
      end
    end
  end
end

module Payments
  class CreatePayment
    def initialize(payment:)
      @payment = payment
    end

    def create
      return payment_url if @payment.payment_url.present?

      params = Payments::Dotpay::AdaptPayment.new(payment: @payment).to_params
      Payments::Dotpay::PaymentRequest.new(params: params).execute
    end

    private

    def payment_url
      Success.new(payment_url: @payment.payment_url)
    end
  end
end

module Payments
  class CreatePayment
    def initialize(payment:)
      @payment = payment
    end

    def create
      params = Payments::Dotpay::AdaptPayment.new(payment: @payment).to_params
      Payments::Dotpay::PaymentRequest.new(params: params).execute
    end
  end
end

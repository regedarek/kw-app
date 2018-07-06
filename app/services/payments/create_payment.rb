module Payments
  class CreatePayment
    def initialize(payment:)
      @payment = payment
    end

    def create
      return payment_url if @payment.payment_url.present?

      params = Payments::Dotpay::AdaptPayment.new(payment: @payment).to_params
      Rails.logger.info "payment_type: #{payment_type}"
      Rails.logger.info "params: #{payment_type}"
      Payments::Dotpay::PaymentRequest.new(params: params, type: payment_type).execute
    end

    private

    def payment_type
      @payment.payable&.payment_type
    end

    def payment_url
      Success.new(payment_url: @payment.payment_url)
    end
  end
end

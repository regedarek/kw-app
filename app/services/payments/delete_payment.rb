module Payments
  class DeletePayment
    def initialize(payment:)
      @payment = payment
    end

    def delete
      Payments::Dotpay::DeletePaymentRequest.new(dotpay_id: @payment.dotpay_id, type: payment_type).execute

      Success.new
    end

    private

    def payment_type
      @payment.payable&.payment_type
    end
  end
end

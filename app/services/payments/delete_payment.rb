module Payments
  class DeletePayment
    def initialize(payment:)
      @payment = payment
    end

    def delete
      Rails.logger.info "initialize deletion"
      code = CGI::parse(@payment.payment_url).values.flatten.first
      Payments::Dotpay::DeletePaymentRequest.new(dotpay_id: code, type: payment_type).execute
      Rails.logger.info "initialize finished"

      Success.new
    end

    private

    def payment_type
      @payment.payable&.payment_type
    end
  end
end

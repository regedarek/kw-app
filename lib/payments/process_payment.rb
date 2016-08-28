module Payments
  class ProcessPayment
    def initialize(payment:, system:)
      @payment = payment
      @system = system
    end

    def call
      fee_class.new(
        email: payment.reservation.user.email,
        amount: payment.amount,
        description: payment.description
      )

      initiate_payment_class.request(fee: fee_class)
    end

    def fee_class
      case @system
      when :dotpay
        Payments::DotPay::ReservationFee
      else
        fail 'wrong system'
      end
    end

    def initiate_payment_class
      case @system
      when :dotpay
        Payments::DotPay::InitiatePayment
      else
        fail 'wrong system'
      end
    end
  end
end

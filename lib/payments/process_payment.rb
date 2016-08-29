module Payments
  class ProcessPayment
    def initialize(payment:, system:)
      @payment = payment
      @system = system
    end

    def call
      fee = fee_class.new(
        email: @payment.reservation.user.email,
        amount: 10,
        description: @payment.description
      )

      initiate_payment_class.new.request(fee: fee)
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

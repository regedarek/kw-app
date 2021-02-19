module Payments
  module Dotpay
    class AdaptPayment
      def initialize(payment:)
        @payment = payment
      end

      def to_params
        {
          amount: @payment.amount || @payment.payable.cost,
          currency: 'PLN',
          description: @payment.payable.description,
          control: @payment.dotpay_id,
          language: 'pl',
          redirection_type: 0,
          url: Rails.application.secrets.dotpay_back_url,
          urlc: Rails.application.secrets.dotpay_urlc
        }
      end
    end
  end
end

module Payments
  module Dotpay
    class AdaptPayment
      def initialize(payment:)
        @payment = payment
      end

      def to_params
        {
          amount: @payment.order.cost,
          currency: 'PLN',
          description: @payment.description,
          control: @payment.dotpay_id,
          language: 'pl',
          redirection_type: 0,
          url: Rails.application.secrets.dotpay_url,
          urlc: Rails.application.secrets.dotpay_urlc,
        }
      end
    end
  end
end

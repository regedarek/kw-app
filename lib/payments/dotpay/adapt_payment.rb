module Payments
  module Dotpay
    class AdaptPayment
      def initialize(payment:)
        @payment = payment
      end

      def to_params
        {
          amount: 10,
          currency: 'PLN',
          description: 'Platnosc za rezerwacje',
          control: 1234,
          language: 'pl',
          redirection_type: 0,
          url: 'https://e346eada.ngrok.io/api/payments/thank_you',
          urlc: 'https://e346eada.ngrok.io/api/payments/status'
        }
      end
    end
  end
end

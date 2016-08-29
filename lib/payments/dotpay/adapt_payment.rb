module Payments
  module Dotpay
    class AdaptPayment
      def initialize(payment:)
        @payment = payment
      end

      def to_params
        {
          amount: reservation.items.map(&:cost).reduce(:+),
          currency: 'PLN',
          description: "Platnosc za rezerwacje ##{reservation.id}",
          control: @payment.dotpay_id,
          language: 'pl',
          redirection_type: 0,
          url: 'https://e346eada.ngrok.io/api/payments/thank_you',
          urlc: 'https://e346eada.ngrok.io/api/payments/status'
        }
      end

      def reservation
        @payment.reservation
      end
    end
  end
end

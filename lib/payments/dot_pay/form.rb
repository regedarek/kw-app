module Payments
  module DotPay
    class Form < FormObject
      attribute :id, Integer, default: Payments::DotPay::ReservationFee::CLIENT_ID
      attribute :amount, Integer, default: 10
      attribute :currency, String, default: 'PLN'
      attribute :description, String, default: 'test'
      attribute :url, String, default: Payments::DotPay::ReservationFee::DEFAULT_BACK_URL
      attribute :urlc, String, default: Payments::DotPay::ReservationFee::URLC
      attribute :control, Integer, default: '12334'
      attribute :email, String, default: 'darek.finster@gmail.com'

      def request_url
        'https://ssl.dotpay.pl/test_payment'
      end
    end
  end
end

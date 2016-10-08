require 'net/https'
require 'uri'
require 'results'

module Payments
  module Dotpay
    class PaymentRequest
      def initialize(params:)
        @params = params
      end

      def execute
        account_id = Rails.application.secrets.dotpay_id
        uri = URI.parse("https://ssl.dotpay.pl/test_seller/api/accounts/#{account_id}/payment_links/?format=json")

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Post.new(uri.request_uri)
        request.basic_auth(
          Rails.application.secrets.dotpay_login,
          Rails.application.secrets.dotpay_password
        )
        request.set_form_data(@params)
        response = http.request(request)
        payment_url = JSON.parse(response.body).fetch('payment_url')
        Success.new(payment_url: payment_url)
      end
    end
  end
end

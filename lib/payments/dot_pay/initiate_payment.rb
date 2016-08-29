require 'net/http'
require 'net/https'
require 'uri'

module Payments
  module DotPay
    class InitiatePayment
      def self.uri
        if Rails.env.production?
          URI.parse('https://ssl.dotpay.pl/t2/')
        else
          URI.parse('https://ssl.dotpay.pl/test_payment/')
        end
      end

      def request(fee:)
        request = Net::HTTP::Post.new('https://ssl.dotpay.pl/test_payment/')
        request.set_form_data(fee.to_h.merge(api_version: 'dev'))

        if fee.valid?
          https.request(request)
        else
          fee.errors
        end
      end

      private

      def https
        http = Net::HTTP.new(self.class.uri.host, self.class.uri.port)
        http.use_ssl = true
        http
      end
    end
  end
end

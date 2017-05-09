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
        uri = URI.parse(Rails.application.secrets.dotpay_base_url + "accounts/#{account_id}/payment_links/?format=json")

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
        request.basic_auth(
          Rails.application.secrets.dotpay_login,
          Rails.application.secrets.dotpay_password
        )
        request.body = @params.to_json
        response = http.request(request)

        case response
        when Net::HTTPSuccess, Net::HTTPRedirection
          payment_url = JSON.parse(response.body).fetch('payment_url')
          if payment_url.present?
            Success.new(payment_url: payment_url)
          else
            Failure.new(:wrong_payment_url, message: 'Błędny link płatności, skonktaktuj się z opiekunem')
          end
        else
          Failure.new(:dotpay_request_error, message: 'Błąd podczas generowania linka płatności skontaktuj sie z opiekunem')
        end

      end
    end
  end
end

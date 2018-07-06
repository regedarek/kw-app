require 'uri'
require 'results'

module Payments
  module Dotpay
    class PaymentRequest
      def initialize(params:, type:)
        @params = params
        @type = type
      end

      def execute
        Rails.logger.info "ACCOUNT_ID: #{account_id}"
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
            Failure.new(:wrong_payment_url, message: 'Błędny link płatności, skonktaktuj się z administratorem.')
          end
        else
          Failure.new(:dotpay_request_error, message: 'Błąd podczas generowania linka płatności skontaktuj sie z administratorem.')
        end
      end

      private

      def account_id
        case @type
        when :fees
          Rails.application.secrets.dotpay_fees_id
        when :reservations
          Rails.application.secrets.dotpay_reservations_id
        when :trainings
          Rails.application.secrets.dotpay_trainings_id
        else
          Rails.application.secrets.dotpay_fees_id
        end
      end
    end
  end
end

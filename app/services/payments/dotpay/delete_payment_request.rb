require 'uri'
require 'results'

module Payments
  module Dotpay
    class DeletePaymentRequest
      def initialize(code:, type:)
        @code = code
        @type = type
      end

      def execute
        uri = URI.parse(Rails.application.secrets.dotpay_base_url + "accounts/#{account_id}/payment_links/#{@code}/?format=json")

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Delete.new(uri.request_uri, 'Content-Type' => 'application/json')
        request.basic_auth(
          Rails.application.secrets.dotpay_login,
          Rails.application.secrets.dotpay_password
        )

        response = http.request(request)
        case response
        when Net::HTTPSuccess, Net::HTTPRedirection
          Success.new
        else
          Failure.new(:dotpay_request_error, message: 'Błąd podczas usuwania linka płatności skontaktuj sie z administratorem.')
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
        when :donations
          Rails.application.secrets.dotpay_donations_id
        else
          Rails.application.secrets.dotpay_fees_id
        end
      end
    end
  end
end

require 'uri'
require 'results'

module Payments
  module Dotpay
    class GetOperationRequest
      def initialize(code:)
        @code = code
      end

      def execute
        return Failure.new(:payment_code_needed, message: 'Musisz podać numer transakcji!') unless @code

        uri = URI.parse(Rails.application.secrets.dotpay_base_url + "operations/?type=payment&status=completed&control=#{@code}&format=json")

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Get.new(uri.request_uri, 'Content-Type' => 'application/json')
        request.basic_auth(
          Rails.application.secrets.dotpay_login,
          Rails.application.secrets.dotpay_password
        )

        response = http.request(request)
        case response
        when Net::HTTPSuccess, Net::HTTPRedirection
          Success.new
        else
          Failure.new(:dotpay_request_error, message: 'Błąd podczas dokonywania zwrotu płatności skontaktuj sie z administratorem.')
        end
      end
    end
  end
end

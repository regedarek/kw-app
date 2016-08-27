require 'net/http'
require 'net/https'
require 'uri'
require 'results'

module Payments
  class InitializeDotPay
    def self.uri
      URI.parse('https://ssl.dotpay.pl/t2/')
    end

    def initialize(reservation_id:, fee: Payments::Fee.new)
      @fee = fee
      @reservation_id = reservation_id
    end

    def create
      request = Net::HTTP::Post.new(self.class.uri.path)
      request.set_form_data(@fee.to_h.merge(api_version: 'dev'))

      if @fee.valid?
        response = https.request(request)
        reservation_payment = Db::Reservation.find(@reservation_id).reservation_payment
        reservation_payment.update(dot_pay_id: response.fetch('dot_pay_id'))
        Success.new
      else
        Failure.new(errors: @fee.errors)
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

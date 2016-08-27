require 'net/http'
require 'net/https'
require 'uri'

module Payments
  class Create
    def self.uri
      URI.parse('https://ssl.dotpay.pl/t2/')
    end

    def initialize(fee: Payments::Fee.new)
      @fee = fee
    end

    def call
      request = Net::HTTP::Post.new(self.class.uri.path)
      request.set_form_data(@fee.to_h.merge(api_version: 'dev'))

      if @fee.valid?
        https.request(request)
      else
        @fee.errors
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

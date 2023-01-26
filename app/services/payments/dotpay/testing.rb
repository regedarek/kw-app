charity = Charity::DonationRecord.last
payment = charity.payment

params = Payments::Dotpay::AdaptPayment.new(payment: payment).to_params

uri = URI.parse('https://ssl.dotpay.pl/s2/login/api/v1/' + "accounts/#{Rails.application.secrets.dotpay_fees_id}/payment_links/?format=json")

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
request.basic_auth(
  Rails.application.secrets.dotpay_login,
  Rails.application.secrets.dotpay_password
)
request.body = params.to_json
response = http.request(request)

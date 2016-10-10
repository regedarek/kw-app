require 'rails_helper'
require 'payments'

describe PaymentsController, type: :controller do
  render_views
  let!(:user)      { Factories::User.create!(first_name: 'Olek') }
  let!(:order)   { Factories::Order.create! }
  let!(:payment)   { Factories::Payment.create!(order_id: order.id) }
  let(:code)   { 200 }
  let(:body)   { '' }

  before do
    sign_in(user)
    stub_payment_request(code, body)
  end

  describe '#charge' do
    context '200' do
      let(:body) { { payment_url: 'https://ssl.dotpay.pl/test_payment/?pid=gi10hpwhk4o5xihnql675gjxmt65iyzk' }.to_json }

      it 'redirects to dotpay page' do
        post :charge, id: payment.id

        expect(response).to redirect_to('https://ssl.dotpay.pl/test_payment/?pid=gi10hpwhk4o5xihnql675gjxmt65iyzk')
      end
    end

    context '404' do
      let(:code) { 404 } 

      it 'redirects to dotpay page' do
        post :charge, id: payment.id

        expect(response).to redirect_to(root_path)
      end
    end

    context '400' do
      let(:code) { 400 } 

      it 'redirects to dotpay page' do
        post :charge, id: payment.id

        expect(response).to redirect_to(root_path)
      end
    end

    context '500' do
      let(:code) { 500 } 

      it 'redirects to dotpay page' do
        post :charge, id: payment.id

        expect(response).to redirect_to(root_path)
      end
    end
  end
end

def stub_payment_request(code, body)
  stub_request(:post, "https://ssl.dotpay.pl/test_seller/api/accounts//payment_links/?format=json").
    with(:body => {"amount"=>nil, "control"=>"4352b0b9f9577f216103ce9cc9", "currency"=>"PLN", "description"=>"Opłata za zamówienie #1", "language"=>"pl", "redirection_type"=>"0", "url"=>nil, "urlc"=>nil},
         :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Basic Og==', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}).
    to_return(:status => code, :body => body, :headers => {})
end

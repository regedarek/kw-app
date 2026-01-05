require 'rails_helper'
require 'webmock/rspec'

describe Membership::PayFee do
  before(:each) { Db::Membership::Fee.destroy_all }
  before do
    Factories::User.create!(kw_id: 1111)
    
    # Stub external Dotpay API calls
    stub_request(:post, /ssl\.dotpay\.pl/).
      to_return(status: 200, body: '{"payment_url":"http://example.com/payment"}', headers: {'Content-Type' => 'application/json'})
  end

  describe '.pay' do
    context 'Result keyword argument handling' do
      it 'returns invalid result with form as keyword argument when form is invalid' do
        # Create an invalid form (missing year)
        form = Membership::FeeForm.new(kw_id: 1111, plastic: false)
        expect(form.valid?).to be false

        result = Membership::PayFee.pay(kw_id: 1111, form: form)

        # This test ensures the Result class properly passes keyword arguments
        # It should not raise ArgumentError: missing keyword: :form
        expect do
          result.invalid { |form:| 
            expect(form).to eq(form)
            expect(form.errors).to be_present
          }
        end.not_to raise_error

        expect(result.invalid?).to be true
      end

      it 'returns success result with payment as keyword argument when form is valid' do
        form = Membership::FeeForm.new(kw_id: 1111, year: (Date.today.year + 1).to_s, plastic: false)
        expect(form.valid?).to be true

        result = Membership::PayFee.pay(kw_id: 1111, form: form)

        # This test ensures the Result class properly passes keyword arguments
        # It should not raise ArgumentError: missing keyword: :payment
        captured_payment = nil
        expect do
          result.success { |payment:| 
            captured_payment = payment
          }
        end.not_to raise_error
        
        expect(captured_payment).to be_a(Db::Payment)
        expect(captured_payment.dotpay_id).to be_present
      end
    end
    xit 'no payments, pay for current' do
      form = Membership::FeeForm.new(year: 2017)
      expect(Db::Membership::Fee.count).to eq(0)
      Membership::PayFee.pay(kw_id: 1111, form: form)
      expect(Db::Membership::Fee.count).to eq(1)
      expect(Db::Membership::Fee.find_by(kw_id: 1111, year: 2017).cost).to eq(150)
    end

    xit 'no payments, pay for next' do
      form = Membership::FeeForm.new(year: 2018)
      expect(Db::Membership::Fee.count).to eq(0)
      Membership::PayFee.pay(kw_id: 1111, form: form)
      expect(Db::Membership::Fee.count).to eq(1)
      expect(Db::Membership::Fee.find_by(kw_id: 1111, year: 2018).cost).to eq(150)
    end

    xit 'last year payment, pay for current' do
      fee = Db::Membership::Fee.create!(kw_id: 1111, year: 2016)
      order = Orders::CreateOrder.new(service: fee).create
      order.payment.charge!

      form = Membership::FeeForm.new(year: 2017)
      expect(Db::Membership::Fee.count).to eq(1)
      Membership::PayFee.pay(kw_id: 1111, form: form)
      expect(Db::Membership::Fee.count).to eq(2)
      expect(Db::Membership::Fee.find_by(kw_id: 1111).cost).to eq(100)
    end

    xit 'current payment, pay for next year' do
      fee = Db::Membership::Fee.create!(kw_id: 1111, year: 2017)
      order = Orders::CreateOrder.new(service: fee).create
      order.payment.charge!

      form = Membership::FeeForm.new(year: 2018)
      expect(Db::Membership::Fee.count).to eq(1)
      Membership::PayFee.pay(kw_id: 1111, form: form)
      expect(Db::Membership::Fee.count).to eq(2)
      expect(Db::Membership::Fee.find_by(kw_id: 1111).cost).to eq(100)
    end

    xit 'last year payment by cash, pay for current' do
      fee = Db::Membership::Fee.create!(kw_id: 1111, year: 2016)
      order = Orders::CreateOrder.new(service: fee).create
      order.payment.update(cash: true)

      form = Membership::FeeForm.new(year: 2017)
      expect(Db::Membership::Fee.count).to eq(1)
      Membership::PayFee.pay(kw_id: 1111, form: form)
      expect(Db::Membership::Fee.count).to eq(2)
      expect(Db::Membership::Fee.find_by(kw_id: 1111).cost).to eq(100)
    end

    xit 'last year payment, pay for next' do
      Db::Membership::Fee.create!(kw_id: 1111, year: 2016)
      form = Membership::FeeForm.new(year: 2018)
      expect(Db::Membership::Fee.count).to eq(1)
      Membership::PayFee.pay(kw_id: 1111, form: form)
      expect(Db::Membership::Fee.count).to eq(2)
      expect(Db::Membership::Fee.find_by(kw_id: 1111).cost).to eq(150)
    end

    xit 'gap in payments, pay for current' do
      Db::Membership::Fee.create!(kw_id: 1111, year: 2014)
      form = Membership::FeeForm.new(year: 2017)
      expect(Db::Membership::Fee.count).to eq(1)
      Membership::PayFee.pay(kw_id: 1111, form: form)
      expect(Db::Membership::Fee.count).to eq(2)
      expect(Db::Membership::Fee.find_by(kw_id: 1111).cost).to eq(150)
    end

    xit 'gap in payments, pay for next' do
      Db::Membership::Fee.create!(kw_id: 1111, year: 2014)
      form = Membership::FeeForm.new(year: 2018)
      expect(Db::Membership::Fee.count).to eq(1)
      Membership::PayFee.pay(kw_id: 1111, form: form)
      expect(Db::Membership::Fee.count).to eq(2)
      expect(Db::Membership::Fee.find_by(kw_id: 1111).cost).to eq(150)
    end
  end
end

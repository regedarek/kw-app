require 'rails_helper'
require 'webmock/rspec'

describe Membership::PayFee do
  let!(:user) { create(:user, kw_id: 1111) }
  
  before do
    Db::Membership::Fee.destroy_all
    Timecop.freeze('2017-06-15'.to_date)
    
    # Stub external Dotpay API calls
    stub_request(:post, /ssl\.dotpay\.pl/).
      to_return(status: 200, body: '{"payment_url":"http://example.com/payment"}', headers: {'Content-Type' => 'application/json'})
  end
  
  after { Timecop.return }

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
    it 'no payments, pay for current' do
      form = Membership::FeeForm.new(kw_id: 1111, year: '2017', plastic: false)
      expect(form.valid?).to be true
      
      expect(Db::Membership::Fee.count).to eq(0)
      
      result = Membership::PayFee.pay(kw_id: 1111, form: form)
      
      expect(result.success?).to be true
      expect(Db::Membership::Fee.count).to eq(1)
      
      fee = Db::Membership::Fee.find_by(kw_id: 1111, year: 2017)
      expect(fee.cost).to eq(200) # Gap in payments (no previous year) = regular 200 PLN
      expect(fee.payment).to be_present
      expect(fee.payment.dotpay_id).to be_present
    end

    it 'no payments, pay for next' do
      form = Membership::FeeForm.new(kw_id: 1111, year: '2018', plastic: false)
      expect(form.valid?).to be true
      
      expect(Db::Membership::Fee.count).to eq(0)
      
      result = Membership::PayFee.pay(kw_id: 1111, form: form)
      
      expect(result.success?).to be true
      expect(Db::Membership::Fee.count).to eq(1)
      
      fee = Db::Membership::Fee.find_by(kw_id: 1111, year: 2018)
      expect(fee.cost).to eq(200) # Gap in payments (no previous year) = regular 200 PLN
      expect(fee.payment).to be_present
    end

    it 'last year payment, pay for current' do
      # Create paid membership for last year (2016) using factory
      last_year_fee = create(:membership_fee, :paid, kw_id: 1111, year: 2016)
      expect(last_year_fee.payment.paid?).to be true

      form = Membership::FeeForm.new(kw_id: 1111, year: '2017', plastic: false)
      expect(Db::Membership::Fee.count).to eq(1)
      
      result = Membership::PayFee.pay(kw_id: 1111, form: form)
      
      expect(result.success?).to be true
      expect(Db::Membership::Fee.count).to eq(2)
      
      current_fee = Db::Membership::Fee.find_by(kw_id: 1111, year: 2017)
      expect(current_fee.cost).to eq(150) # Continuous payment = regular 150 PLN
    end

    it 'current payment, pay for next year' do
      # Create paid membership for current year (2017) using factory
      current_fee = create(:membership_fee, :paid, kw_id: 1111, year: 2017)
      expect(current_fee.payment.paid?).to be true

      form = Membership::FeeForm.new(kw_id: 1111, year: '2018', plastic: false)
      expect(Db::Membership::Fee.count).to eq(1)
      
      result = Membership::PayFee.pay(kw_id: 1111, form: form)
      
      expect(result.success?).to be true
      expect(Db::Membership::Fee.count).to eq(2)
      
      next_fee = Db::Membership::Fee.find_by(kw_id: 1111, year: 2018)
      expect(next_fee.cost).to eq(150) # Current year paid, prepaying next = regular 150 PLN
    end

    it 'last year payment by cash, pay for current' do
      # Create cash-paid membership for last year (2016) using factory
      last_year_fee = create(:membership_fee, :cash, kw_id: 1111, year: 2016)
      expect(last_year_fee.payment.cash?).to be true
      expect(last_year_fee.payment.paid?).to be true

      form = Membership::FeeForm.new(kw_id: 1111, year: '2017', plastic: false)
      expect(Db::Membership::Fee.count).to eq(1)
      
      result = Membership::PayFee.pay(kw_id: 1111, form: form)
      
      expect(result.success?).to be true
      expect(Db::Membership::Fee.count).to eq(2)
      
      current_fee = Db::Membership::Fee.find_by(kw_id: 1111, year: 2017)
      expect(current_fee.cost).to eq(150) # Continuous payment (cash counts) = regular 150 PLN
    end

    it 'last year payment, pay for next' do
      # Create unpaid membership for last year (2016) - payment exists but not paid
      last_year_fee = create(:membership_fee, :unpaid, kw_id: 1111, year: 2016)
      expect(last_year_fee.payment.paid?).to be false
      
      form = Membership::FeeForm.new(kw_id: 1111, year: '2018', plastic: false)
      expect(Db::Membership::Fee.count).to eq(1)
      
      result = Membership::PayFee.pay(kw_id: 1111, form: form)
      
      expect(result.success?).to be true
      expect(Db::Membership::Fee.count).to eq(2)
      
      next_fee = Db::Membership::Fee.find_by(kw_id: 1111, year: 2018)
      expect(next_fee.cost).to eq(200) # Gap in payments (2016 unpaid, skipping 2017) = regular 200 PLN
    end

    it 'gap in payments, pay for current' do
      # Create unpaid membership for 2014 (large gap)
      old_fee = create(:membership_fee, :unpaid, kw_id: 1111, year: 2014)
      
      form = Membership::FeeForm.new(kw_id: 1111, year: '2017', plastic: false)
      expect(Db::Membership::Fee.count).to eq(1)
      
      result = Membership::PayFee.pay(kw_id: 1111, form: form)
      
      expect(result.success?).to be true
      expect(Db::Membership::Fee.count).to eq(2)
      
      current_fee = Db::Membership::Fee.find_by(kw_id: 1111, year: 2017)
      expect(current_fee.cost).to eq(200) # Gap in payments (2014 to 2017) = regular 200 PLN
    end

    it 'gap in payments, pay for next' do
      # Create unpaid membership for 2014 (large gap)
      old_fee = create(:membership_fee, :unpaid, kw_id: 1111, year: 2014)
      
      form = Membership::FeeForm.new(kw_id: 1111, year: '2018', plastic: false)
      expect(Db::Membership::Fee.count).to eq(1)
      
      result = Membership::PayFee.pay(kw_id: 1111, form: form)
      
      expect(result.success?).to be true
      expect(Db::Membership::Fee.count).to eq(2)
      
      next_fee = Db::Membership::Fee.find_by(kw_id: 1111, year: 2018)
      expect(next_fee.cost).to eq(200) # Gap in payments (2014 to 2018) = regular 200 PLN
    end
  end
end

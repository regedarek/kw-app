require 'rails_helper'

describe Membership::PayFee do
  before(:each) { Db::Membership::Fee.destroy_all }

  describe '.pay' do
    it 'no payments, pay for current' do
      form = Membership::FeeForm.new(year: 2017)
      expect(Db::Membership::Fee.count).to eq(0)
      Membership::PayFee.pay(kw_id: 1111, form: form)
      expect(Db::Membership::Fee.count).to eq(1)
      expect(Db::Membership::Fee.find_by(kw_id: 1111, year: 2017).cost).to eq(150)
    end

    it 'no payments, pay for next' do
      form = Membership::FeeForm.new(year: 2018)
      expect(Db::Membership::Fee.count).to eq(0)
      Membership::PayFee.pay(kw_id: 1111, form: form)
      expect(Db::Membership::Fee.count).to eq(1)
      expect(Db::Membership::Fee.find_by(kw_id: 1111, year: 2018).cost).to eq(150)
    end

    it 'last year payment, pay for current' do
      fee = Db::Membership::Fee.create!(kw_id: 1111, year: 2016)
      order = Orders::CreateOrder.new(service: fee).create
      order.payment.charge!

      form = Membership::FeeForm.new(year: 2017)
      expect(Db::Membership::Fee.count).to eq(1)
      Membership::PayFee.pay(kw_id: 1111, form: form)
      expect(Db::Membership::Fee.count).to eq(2)
      expect(Db::Membership::Fee.find_by(kw_id: 1111).cost).to eq(100)
    end

    it 'current payment, pay for next year' do
      fee = Db::Membership::Fee.create!(kw_id: 1111, year: 2017)
      order = Orders::CreateOrder.new(service: fee).create
      order.payment.charge!

      form = Membership::FeeForm.new(year: 2018)
      expect(Db::Membership::Fee.count).to eq(1)
      Membership::PayFee.pay(kw_id: 1111, form: form)
      expect(Db::Membership::Fee.count).to eq(2)
      expect(Db::Membership::Fee.find_by(kw_id: 1111).cost).to eq(100)
    end

    it 'last year payment by cash, pay for current' do
      fee = Db::Membership::Fee.create!(kw_id: 1111, year: 2016)
      order = Orders::CreateOrder.new(service: fee).create
      order.payment.update(cash: true)

      form = Membership::FeeForm.new(year: 2017)
      expect(Db::Membership::Fee.count).to eq(1)
      Membership::PayFee.pay(kw_id: 1111, form: form)
      expect(Db::Membership::Fee.count).to eq(2)
      expect(Db::Membership::Fee.find_by(kw_id: 1111).cost).to eq(100)
    end

    it 'last year payment, pay for next' do
      Db::Membership::Fee.create!(kw_id: 1111, year: 2016)
      form = Membership::FeeForm.new(year: 2018)
      expect(Db::Membership::Fee.count).to eq(1)
      Membership::PayFee.pay(kw_id: 1111, form: form)
      expect(Db::Membership::Fee.count).to eq(2)
      expect(Db::Membership::Fee.find_by(kw_id: 1111).cost).to eq(150)
    end

    it 'gap in payments, pay for current' do
      Db::Membership::Fee.create!(kw_id: 1111, year: 2014)
      form = Membership::FeeForm.new(year: 2017)
      expect(Db::Membership::Fee.count).to eq(1)
      Membership::PayFee.pay(kw_id: 1111, form: form)
      expect(Db::Membership::Fee.count).to eq(2)
      expect(Db::Membership::Fee.find_by(kw_id: 1111).cost).to eq(150)
    end

    it 'gap in payments, pay for next' do
      Db::Membership::Fee.create!(kw_id: 1111, year: 2014)
      form = Membership::FeeForm.new(year: 2018)
      expect(Db::Membership::Fee.count).to eq(1)
      Membership::PayFee.pay(kw_id: 1111, form: form)
      expect(Db::Membership::Fee.count).to eq(2)
      expect(Db::Membership::Fee.find_by(kw_id: 1111).cost).to eq(150)
    end
  end
end

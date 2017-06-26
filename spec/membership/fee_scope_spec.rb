require 'rails_helper'

describe UserManagement::FeeScope do
  before do
    Db::Membership::Fee.create!(year: 2015, cost: 100, kw_id: 2345)
    fee_1 = Db::Membership::Fee.create!(year: 2015, cost: 100, kw_id: 2346)
    fee_1.create_payment(cash: true, dotpay_id: '321321', state: 'prepaid', payable_type: 'Db::Membership::Fee', payable_id: fee_1.id)
    fee_2 = Db::Membership::Fee.create!(year: 2015, cost: 100, kw_id: 2347)
    fee_2.create_payment(cash: true, dotpay_id: '321321', state: 'prepaid', payable_type: 'Db::Membership::Fee', payable_id: fee_2.id)
    fee_3 = Db::Membership::Fee.create!(year: 2015, cost: 100, kw_id: 2348)
    fee_3.create_payment(cash: false, dotpay_id: '321321', state: 'unpaid', payable_type: 'Db::Membership::Fee', payable_id: fee_3.id)
    fee_4 = Db::Membership::Fee.create!(year: 2015, cost: 100, kw_id: 2349)
    fee_4.create_payment(cash: false, dotpay_id: '321321', state: 'prepaid', payable_type: 'Db::Membership::Fee', payable_id: fee_4.id)
    fee_5 = Db::Membership::Fee.create!(year: 2015, cost: 100, kw_id: 2350)
    fee_5.create_payment(cash: false, dotpay_id: '321321', state: 'prepaid', payable_type: 'Db::Membership::Fee', payable_id: fee_5.id)
  end

  describe '.for' do
    it 'returns prepaided fees' do
      expect(UserManagement::FeeScope.for(year: 2015)).to eq(4)
    end
  end
end

require 'rails_helper'

describe Membership::FeesRepository do
  let(:fee_1) { Db::Membership::Fee.create!(year: 2015, cost: 100, kw_id: 2346) }
  let(:fee_2) { Db::Membership::Fee.create!(year: 2016, cost: 100, kw_id: 2347) }
  let(:fee_3) { Db::Membership::Fee.create!(year: 2016, cost: 100, kw_id: 2348) }
  let(:fee_4) { Db::Membership::Fee.create!(year: 2016, cost: 100, kw_id: 2349) }
  let(:fee_5) { Db::Membership::Fee.create!(year: 2016, cost: 150, kw_id: 2350) }
  let(:fee_6) { Db::Membership::Fee.create!(year: 2017, cost: 100, kw_id: 2350) }
  let(:fee_7) { Db::Membership::Fee.create!(year: 2018, cost: 100, kw_id: 2351) }
  let(:fee_8) { Db::Membership::Fee.create!(year: 2019, cost: 100, kw_id: 2351) }

  before do
    Timecop.freeze('2018-03-01'.to_date)
    fee_1.create_payment(cash: true, dotpay_id: '321322', state: 'prepaid', payable_type: 'Db::Membership::Fee', payable_id: fee_1.id)
    fee_2.create_payment(cash: true, dotpay_id: '321321', state: 'prepaid', payable_type: 'Db::Membership::Fee', payable_id: fee_2.id)
    fee_3.create_payment(cash: false, dotpay_id: '321321', state: 'prepaid', payable_type: 'Db::Membership::Fee', payable_id: fee_3.id)
    fee_4.create_payment(cash: false, dotpay_id: '321321', state: 'unpaid', payable_type: 'Db::Membership::Fee', payable_id: fee_4.id)
    fee_5.create_payment(cash: false, dotpay_id: '321321', state: 'prepaid', payable_type: 'Db::Membership::Fee', payable_id: fee_5.id)
    fee_6.create_payment(cash: false, dotpay_id: '321321', state: 'prepaid', payable_type: 'Db::Membership::Fee', payable_id: fee_6.id)
    fee_7.create_payment(cash: false, dotpay_id: '321321', state: 'prepaid', payable_type: 'Db::Membership::Fee', payable_id: fee_7.id)
    fee_8.create_payment(cash: false, dotpay_id: '321321', state: 'prepaid', payable_type: 'Db::Membership::Fee', payable_id: fee_8.id)
  end

  after { Timecop.return }

  describe '#find_paid_two_years_ago' do
    it 'returns prepaided fees' do
      expect(Membership::FeesRepository.new.find_paid_two_years_ago)
        .to match_array([fee_2, fee_3, fee_5])
    end
  end

  describe '#get_kw_ids' do
    it 'returns ids' do
      expect(Membership::FeesRepository.new.get_unpaid_kw_ids_this_year)
        .to match_array([2347, 2348, 2350])
    end
  end
end

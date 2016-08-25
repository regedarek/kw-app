require 'rails_helper'

describe Reservations::CreateReservation do
  let!(:user) { Factories::User.create! }
  let!(:item) { Factories::Item.create! }
  let(:valid_params) do
    {
      start_date: '2016-08-25',
      end_date: '2016-09-01',
      kw_id: user.kw_id,
      item_ids: [item.id]
    }
  end
  before { Timecop.freeze('2016-08-24'.to_date) }
  after { Timecop.return }

  context 'start_date is not thursday' do
    it 'does not show warning' do
      expect{ described_class.from(params: valid_params) }.not_to raise_error('start date has to be thursday')
    end
  end

  context 'start_date is in the past' do
    xit 'fails'
  end
  
  context 'end_date is not thursday' do
    let(:invalid_params) { valid_params.merge(end_date: '2016-08-26') }
    it 'fails' do
      expect{ described_class.from(params: invalid_params) }.to raise_error('end date has to be thursday')
    end
  end

  context 'end_date is not one week later' do
    let(:invalid_params) { valid_params.merge(end_date: '2016-09-08') }
    it 'fails' do
      expect{ described_class.from(params: invalid_params) }
        .to raise_error('end date has to be one week later')
    end
  end

  xit 'has to be at least one item'

  context 'dates are overlaping' do
    xit 'fails'
  end

  context 'start_date is thursday in the future' do
    xit 'sends email'
    xit 'creates reservation for first item but assigns next to existing one'
  end

  context 'other person reserved item in this time' do
    xit 'fails'
  end

  it 'initialize payment' do
    expect{ described_class.from(params: valid_params) }.to change(Db::Reservation, :count).by(1)
    expect{ described_class.from(params: valid_params) }.to change(Db::ReservationPayment, :count).by(1)
  end
end

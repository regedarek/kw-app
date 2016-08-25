require 'rails_helper'

describe Reservations::CreateReservation do
  let!(:user) { Factories::User.create! }
  let(:valid_params) do
    {
      start_date: '2016-08-24',
      end_date: '2016-09-01',
      kw_id: user.kw_id
    }
  end

  context 'start_date is not thursday' do
    it 'does not show warning' do
      expect{ described_class.from(params: valid_params) }.not_to raise_error('start date has to be thursday')
    end
  end

  context 'start_date is in the past' do
    xit 'fails'
  end
  
  context 'end_date is not valid' do
    xit 'fails'
  end

  xit 'has to be at least one item'

  xit 'reservation items have to be uniqe'

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

  xit 'initialize payment'
end

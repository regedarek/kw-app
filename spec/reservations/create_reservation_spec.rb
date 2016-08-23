require 'rails_helper'

describe Reservation::CreateReservation do
  before do
  end

  context 'start_date is not thursday' do
    xit 'fails'
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
end

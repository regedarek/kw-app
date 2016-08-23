require 'rails_helper'

describe ReservationsController, type: :controller do
  before do
  end

  describe '#index' do
    context 'without start_date param' do
      xit 'shows only available items for current week'
    end

    context 'with start_date in the past' do
      xit 'shows warning'
    end

    context 'with start_date which is not thursday' do
      xit 'shows avaliable items from next thursday'
    end

    context 'with proper start_date' do
      xit 'shows available items for proper week'
      xit 'shows my reservation with items if exists and hide them from available items'
    end
  end
end

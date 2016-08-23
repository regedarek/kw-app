require 'rails_helper'
require './lib/availability/items'

describe Availability::Items do
  let!(:item1) { Db::Item.create(name: 'Czekan 1') }
  let!(:item2) { Db::Item.create(name: 'Czekan 2') }
  let!(:item3) { Db::Item.create(name: 'Czekan 3') }
  before do
    Db::Reservation.create(
      item: item1,
      user_id: 1,
      start_date: '2016-09-01'.to_date,
      end_date: '2016-09-08'.to_date
    )
    Db::Reservation.create(
      item: item2,
      user_id: 1,
      start_date: '2016-09-08'.to_date,
      end_date: '2016-09-15'.to_date
    )
  end
  subject { described_class.new(start_date: '2016-09-01').collect }

  context 'start_date in the past' do
    xit 'returns warning'
  end

  context 'start_date is not thursday' do
    xit 'returns available items for week since next thursday'
  end

  context 'start_date is thursday' do
    xit 'returns available items for proper week'
  end

  it { expect(subject).not_to include(item1) }
  it { expect(subject).to include(item2) }
  it { expect(subject).to include(item3) }
end

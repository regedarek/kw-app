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

  it { expect(subject).not_to include(item1) }
  it { expect(subject).to include(item2) }
  it { expect(subject).to include(item3) }
end

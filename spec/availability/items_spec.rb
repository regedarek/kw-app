require 'rails_helper'

describe Availability::Items do
  let!(:items) { Factories::Item.create_all! }
  before do
    Factories::Reservation.create!(id: 1, item_ids: [1])
    Factories::Reservation.create!(id: 2, item_ids: [2])
    Factories::Reservation.create!(id: 3, item_ids: [3])
  end
  subject { described_class.new(start_date: '2016-09-01').collect }

  context 'start_date in the past' do
    xit 'returns warning'
  end

  context 'start_date is not thursday' do
    xit 'returns warning'
  end

  context 'start_date is thursday' do
    xit { expect(subject).not_to include(items[0]) }
    xit { expect(subject).to include(items[1]) }
    xit { expect(subject).to include(items[2]) }
    xit 'excludes instructor items'
    xit 'excludes not rentable items'
  end
end

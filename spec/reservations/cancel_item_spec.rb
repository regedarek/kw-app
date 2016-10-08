require 'rails_helper'
require 'reservations'

describe Reservations::CancelItem do
  let!(:item) { Factories::Item.create! }
  it 'removes item from reservation' do
    reservation = Factories::Reservation.create!(item_ids: [item.id])

    result = nil
    expect do
      result = described_class.from(reservation_id: reservation.id).delete(item_id: item.id)
    end.to change { reservation.items.count }.from(1).to(0)

    expect(result.success?).to eq(true)
  end

  it 'if reservation not exists throws error' do
    result = described_class.from(reservation_id: 1).delete(item_id: item.id)

    expect(result.reservation_not_exist?).to eq(true)
  end

  it 'if item not exists throws error' do
    reservation = Factories::Reservation.create!
    result = described_class.from(reservation_id: 1).delete(item_id: 2)

    expect(result.item_not_exist?).to eq(true)
  end
end

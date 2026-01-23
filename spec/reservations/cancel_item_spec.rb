# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reservations::CancelItem do
  let!(:item) { create(:item) }
  
  it 'removes item from reservation and deletes reservation when last item and unpaid' do
    reservation = create(:reservation, :with_specific_item, item: item)
    reservation.create_payment(dotpay_id: SecureRandom.hex(13), state: 'unpaid')
    expect(reservation.items.count).to eq(1)
    
    reservation_id = reservation.id

    result = described_class.from(reservation_id: reservation_id).delete(item_id: item.id)

    expect(result.success?).to eq(true)
    # When last item is removed and payment is unpaid, the entire reservation is deleted
    expect(Db::Reservation.exists?(reservation_id)).to be false
  end

  it 'if reservation not exists throws error' do
    result = described_class.from(reservation_id: 999999).delete(item_id: item.id)

    expect(result.reservation_not_exist?).to eq(true)
  end

  it 'if item not exists throws error' do
    reservation = create(:reservation)
    result = described_class.from(reservation_id: reservation.id).delete(item_id: 999999)

    expect(result.item_not_exist?).to eq(true)
  end
end
require 'rails_helper'

describe ReservationsController, type: :controller do
  before do
    user = Db::User.new(
      kw_id: 1, email: 'test@test.pl',
      first_name: 'Test', last_name: 'Test'
    )
    user.password = 'test'
    user.save
    sign_in(user)
  end
  let(:user) { Db::User.first }
  let!(:item_1) { Db::Item.create(name: 'czekan') }
  let!(:item_2) { Db::Item.create(name: 'raki') }

  describe '#index' do
    xit 'returns available items'
  end

  describe '#create' do
    it 'creates reservation with available items' do
      expect {
        post :create, { start_date: '2016-10-10', item_id: item_1.id }
      }.to change{ Db::Reservation.count }.by(1)

      reservation = Db::Reservation.last

      expect(reservation.items).to eq([item_1])
      expect(response).to redirect_to reservations_path
    end

    it 'adds item to reservation if already exists' do
      Db::Reservation.create(start_date: '2016-10-06', end_date: '2016-10-13', items: [item_1], user: user)
      expect {
        post :create, { start_date: '2016-10-06', item_id: item_2.id }
      }.to change { Db::Reservation.count }.by(0)

      reservation = Db::Reservation.last

      expect(reservation.items.map(&:id)).to eq([item_1.id, item_2.id])
      expect(response).to redirect_to reservations_path
    end
  end
end

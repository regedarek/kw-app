require 'rails_helper'

describe ReservationsController, type: :controller do
  let!(:user)   { Factories::User.create!(first_name: 'Olek') }
  let!(:items)  { Factories::Item.create_all! }
  let(:item_1) { items.first }
  let(:item_2) { items.last }
  before { sign_in(user) }

  describe '#index' do
    it 'redirects to next thursday if start_date is not thursday' do
      expect(get :index, start_date: '2016-08-24')
        .to redirect_to(reservations_path(start_date: '2016-08-25'))
    end
  end

  describe '#create' do
    it 'creates reservation with available items' do
      expect {
        post :create, { start_date: '2016-10-10', item_id: item_1.id }
      }.to change{ Db::Reservation.count }.by(1)

      reservation = Db::Reservation.last


      expect(reservation.items).to match_array([item_1])
      expect(reservation.user_id).to eq(user.id)
      expect(response).to redirect_to reservations_path(start_date: '2016-10-10')
    end

    it 'adds item to reservation if already exists' do
      Db::Reservation.create(start_date: '2016-10-06', end_date: '2016-10-13', items: [item_1], user: user)
      expect {
        post :create, { start_date: '2016-10-06', item_id: item_2.id }
      }.to change { Db::Reservation.count }.by(0)

      reservation = Db::Reservation.last
      expect(reservation.items).to match_array([item_1, item_2])
      expect(response).to redirect_to reservations_path(start_date: '2016-10-06')
    end
  end

  describe '#delete_item' do
    let!(:reservation) { Factories::Reservation.create!(start_date: '2016-10-06', items: [item_1, item_2]) }

    it 'deletes item from registration or registration if it was last one' do
      expect {
        delete :delete_item, { id: reservation, item_id: item_1 }
      }.to change { reservation.items.count }.from(2).to(1)

      expect(response).to redirect_to reservations_path(start_date: '2016-10-06')

      expect {
        delete :delete_item, { id: reservation, item_id: item_2 }
      }.to change { Db::Reservation.count }.from(1).to(0)
      expect(response).to redirect_to reservations_path(start_date: '2016-10-06')
    end
  end
end

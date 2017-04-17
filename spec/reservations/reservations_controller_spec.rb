require 'rails_helper'

describe ReservationsController, type: :controller do
  render_views

  let!(:user)   { Factories::User.create!(first_name: 'Olek') }
  let!(:items)  { Factories::Item.create_all! }
  let(:item_1) { items.first }
  let(:item_2) { items.last }
  before do
    sign_in(user)
    Timecop.freeze('2016-08-17'.to_date)
  end
  after { Timecop.return }

  describe '#index' do
    it 'redirects to next thursday if start_date is not thursday' do
      expect(get :index, start_date: '2016-08-24')
        .to redirect_to(reservations_path(start_date: '2016-08-25'))
    end
  end

  describe '#create' do
    it 'creates reservation with available items' do
      form = Factories::Reservation.build_form
      expect {
        post :create, reservations_form: form.attributes
      }.to change{ Db::Reservation.count }.by(1)

      reservation = Db::Reservation.last

      expect(reservation.items).to match_array([item_1])
      expect(reservation.user).to eq(user)
      expect(response).to redirect_to reservations_path(start_date: '2016-08-18')
    end

    it 'adds item to reservation if already exists' do
      reservation = Factories::Reservation.create!(item_ids: [item_1.id])
      Orders::CreateOrder.new(service: reservation).create
      form = Factories::Reservation.build_form(item_ids: [item_2.id])
      expect {
        post :create, reservations_form: form.attributes
      }.to change { Db::Reservation.count }.by(0)

      reservation = Db::Reservation.last
      expect(reservation.items).to match_array([item_1, item_2])
      expect(response).to redirect_to reservations_path(start_date: '2016-08-18')
    end
  end

  describe '#delete_item' do
    it 'deletes item from registration or registration if it was last one' do
      reservation = Factories::Reservation.create!(
        start_date: '2016-10-06', items: [item_1, item_2]
      )
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

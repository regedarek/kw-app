require 'rails_helper'

describe ReservationsController, type: :controller do
  render_views

  let!(:user)   { create(:user, first_name: 'Olek') }
  let!(:items)  { items = create_list(:item, 6); items }
  let(:item_1) { items.first }
  let(:item_2) { items.last }
  before do
    sign_in(user)
    Timecop.freeze('2016-08-17'.to_date)
  end
  after { Timecop.return }

  describe '#index' do
    it 'redirects to next thursday if start_date is not thursday' do
      expect(get :index, params: { start_date: '2016-08-24' })
        .to redirect_to(reservations_path(start_date: '2016-08-25'))
    end
  end

  describe '#create' do
    it 'creates reservation with available items' do
      form = build(:reservation_form, item_ids: [item_1.id])
      expect {
        post :create, params: { reservations_form: form.attributes }
      }.to change{ Db::Reservation.count }.by(1)

      reservation = Db::Reservation.last

      expect(reservation.items).to match_array([item_1])
      expect(reservation.user).to eq(user)
      expect(response).to redirect_to reservations_path(start_date: '2016-08-18')
    end

    it 'adds item to reservation if already exists' do
      reservation = create(:reservation, :with_specific_item, item: item_1, user: user)
      reservation.create_payment(dotpay_id: SecureRandom.hex(13), state: 'unpaid')
      
      form = build(:reservation_form, item_ids: [item_2.id])
      expect {
        post :create, params: { reservations_form: form.attributes }
      }.to change { Db::Reservation.count }.by(0)

      reservation.reload
      expect(reservation.items).to match_array([item_1, item_2])
      expect(response).to redirect_to reservations_path(start_date: '2016-08-18')
    end
  end

  describe '#delete_item' do
    it 'deletes item from registration or registration if it was last one' do
      reservation = create(:reservation, user: user, start_date: '2016-10-06')
      reservation.items << item_1
      reservation.items << item_2
      reservation.create_payment(dotpay_id: SecureRandom.hex(13), state: 'unpaid')
      
      reservation_id = reservation.id
      
      # Delete first item
      delete :delete_item, params: { id: reservation_id, item_id: item_1.id }
      
      reservation.reload
      expect(reservation.items.count).to eq(1)
      expect(reservation.items).to match_array([item_2])
      expect(response).to redirect_to reservations_path(start_date: '2016-10-06')

      # Delete last item - reservation should be deleted (unpaid)
      expect {
        delete :delete_item, params: { id: reservation_id, item_id: item_2.id }
      }.to change { Db::Reservation.count }.by(-1)
      
      expect(Db::Reservation.exists?(reservation_id)).to be false
      expect(response).to redirect_to reservations_path(start_date: '2016-10-06')
    end
  end
end

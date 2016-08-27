require 'rails_helper'

describe Reservations::CreateReservation do
  let!(:user) { Factories::User.create! }
  let!(:item) { Factories::Item.create! }

  before { Timecop.freeze('2016-08-14'.to_date) }
  after { Timecop.return }

  context 'start_date is not thursday' do
    it 'fails' do
      form = Factories::Reservation.build_form(start_date: '2016-10-10')
      result = Reservations::CreateReservation.create(form: form, user: user)

      expect(result.form_invalid?).to eq(true)
    end
  end

  context 'start_date is in the past' do
    it 'fails' do
      form = Factories::Reservation.build_form(start_date: '2016-08-04')
      result = Reservations::CreateReservation.create(form: form, user: user)

      expect(result.form_invalid?).to eq(true)
    end
  end
  
  context 'end_date is not thursday' do
    it 'fails' do
      form = Factories::Reservation.build_form(end_date: '2016-09-10')
      result = Reservations::CreateReservation.create(form: form, user: user)

      expect(result.form_invalid?).to eq(true)
    end
  end

  context 'end_date is before start_date' do
    it 'fails' do
      form = Factories::Reservation.build_form(start_date: '2016-09-15', end_date: '2016-09-08')
      result = Reservations::CreateReservation.create(form: form, user: user)

      expect(result.form_invalid?).to eq(true)
    end
  end

  context 'end_date is not one week later' do
    it 'fails' do
      form = Factories::Reservation.build_form(start_date: '2016-08-18', end_date: '2016-09-08')
      result = Reservations::CreateReservation.create(form: form, user: user)

      expect(result.form_invalid?).to eq(true)
    end
  end

  it 'has to be at least one item' do
    form = Factories::Reservation.build_form(item_ids: [])
    result = Reservations::CreateReservation.create(form: form, user: user)

    expect(result.form_invalid?).to eq(true)
  end

  context 'other person reserved item in this time' do
    before { Factories::Reservation.create! }

    it 'fails' do
      form = Factories::Reservation.build_form
      result = Reservations::CreateReservation.create(form: form, user: user)

      expect(result.item_already_reserved?).to eq(true)
    end
  end

  context 'start_date is thursday in the future' do
    it 'creates reservation and sends email' do
      form = Factories::Reservation.build_form
      result = Reservations::CreateReservation.create(form: form, user: user)

      expect(Db::Reservation.count).to eq(1)
      expect(Db::ReservationPayment.count).to eq(1)
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(result.success?).to eq(true)

      reservation = Db::Reservation.first
      expect(reservation.start_date).to eq('2016-08-18'.to_date)
      expect(reservation.end_date).to eq('2016-08-25'.to_date)
      expect(reservation.items).to match_array([item])
      expect(reservation.user).to eq(user)
      expect(reservation.availible?).to eq(true)
      expect(reservation.reservation_payment).to eq(Db::ReservationPayment.first)
    end
  end
end

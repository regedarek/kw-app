require 'rails_helper'

describe Reservations::Unpaid do
  before { Timecop.freeze('2016-08-14'.to_date) }
  after { Timecop.return }

  describe '#destroy_all' do
    it 'destroy unpaid reservations after 24 hours' do
      Factories::Item.create!
      reservation = Factories::Reservation.create!
      Orders::CreateOrder.new(service: reservation).create
      expect do
        Timecop.freeze('2016-08-19'.to_date)
        Reservations::Unpaid.new(after: 24.hours).destroy_all
      end.to change(Db::Reservation, :count).from(1).to(0)

      expect do
        Timecop.freeze('2016-08-14'.to_date)
        Reservations::Unpaid.new(after: 24.hours).destroy_all
      end.to change(Db::Reservation, :count).by(0)

      expect do
        Timecop.freeze('2016-08-13'.to_date)
        Reservations::Unpaid.new(after: 24.hours).destroy_all
      end.to change(Db::Reservation, :count).by(0)
    end
  end
end

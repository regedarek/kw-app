require 'rails_helper'

describe Reservations::Unpaid do
  before(:each) do
    Factories::Item.create!
    Timecop.freeze('2016-08-14'.to_date)
    unpaid_reservation = Factories::Reservation.create!(id: 1)
    Timecop.freeze('2016-08-15'.to_date)
    prepaid_reservation = Factories::Reservation.create!(id: 2)
    Orders::CreateOrder.new(service: unpaid_reservation).create
    order = Orders::CreateOrder.new(service: prepaid_reservation).create
    order.payment.charge!
  end
  after { Timecop.return }

  describe '#destroy_all' do
    it 'destroy unpaid reservations after 48 hours' do
      expect do
        Timecop.freeze('2016-08-19'.to_date)
        Reservations::Unpaid.new.destroy_all
      end.to change(Db::Reservation, :count).from(2).to(1)
    end

    it do
      expect do
        Timecop.freeze('2016-08-14'.to_date)
        Reservations::Unpaid.new.destroy_all
      end.to change(Db::Reservation, :count).by(0)
    end

    it do
      expect do
        Timecop.freeze('2016-08-15'.to_date)
        Reservations::Unpaid.new.destroy_all
      end.to change(Db::Reservation, :count).by(0)
    end

    it do
      expect do
        Timecop.freeze('2016-08-16'.to_date)
        Reservations::Unpaid.new.destroy_all
      end.to change(Db::Reservation, :count).by(0)
    end

    it do
      expect do
        Timecop.freeze('2016-08-17'.to_date)
        Reservations::Unpaid.new.destroy_all
      end.to change(Db::Reservation, :count).from(2).to(1)
    end
  end
end

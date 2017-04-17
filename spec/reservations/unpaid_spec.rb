require 'rails_helper'
require 'reservations'

describe Reservations::Unpaid do
  before(:each) do
    Factories::Item.create!
    Factories::User.create!(id: 1)
    Timecop.freeze('2016-08-14'.to_date)
    unpaid_reservation = Factories::Reservation.create!(id: 1)
    Timecop.freeze('2016-08-15'.to_date)
    prepaid_reservation = Factories::Reservation.create!(id: 2)
    Orders::CreateOrder.new(service: unpaid_reservation).create
    order = Orders::CreateOrder.new(service: prepaid_reservation).create
    order.payment.charge!
    cash_prepaid_reservation = Factories::Reservation.create!(id: 3)
    order_cash = Orders::CreateOrder.new(service: cash_prepaid_reservation).create
    order_cash.payment.update(cash: true)
  end
  after { Timecop.return }

  describe '#destroy_all' do
    it 'destroy unpaid reservations after 48 hours' do
      expect do
        Timecop.freeze('2016-08-19'.to_date)
        Reservations::Unpaid.new.destroy_all
      end.to change(Db::Reservation, :count).from(3).to(2)
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
      end.to change(Db::Reservation, :count).from(3).to(2)
    end
  end
end

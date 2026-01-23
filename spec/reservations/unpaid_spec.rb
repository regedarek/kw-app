require 'rails_helper'

describe Reservations::Unpaid do
  let!(:user) { create(:user) }
  let!(:item) { create(:item) }
  
  before(:each) do
    Timecop.freeze('2016-08-14'.to_date)
    @unpaid_reservation = create(:reservation, user: user)
    @unpaid_reservation.items << item
    @unpaid_reservation.create_payment(dotpay_id: SecureRandom.hex(13), state: 'unpaid')
    
    Timecop.freeze('2016-08-15'.to_date)
    @prepaid_reservation = create(:reservation, user: user)
    @prepaid_reservation.items << item
    payment = @prepaid_reservation.create_payment(dotpay_id: SecureRandom.hex(13), state: 'unpaid')
    payment.charge! # Transition to prepaid
    
    @cash_prepaid_reservation = create(:reservation, user: user)
    @cash_prepaid_reservation.items << item
    @cash_prepaid_reservation.create_payment(dotpay_id: SecureRandom.hex(13), cash: true, state: 'prepaid')
  end
  
  after { Timecop.return }

  describe '#destroy_all' do
    it 'destroys unpaid reservations after 48 hours' do
      expect(Db::Reservation.count).to eq(3)
      
      Timecop.freeze('2016-08-19'.to_date)
      expect {
        Reservations::Unpaid.new.destroy_all
      }.to change(Db::Reservation, :count).from(3).to(2)
      
      # Unpaid reservation should be deleted
      expect(Db::Reservation.exists?(@unpaid_reservation.id)).to be false
      # Paid reservations should remain
      expect(Db::Reservation.exists?(@prepaid_reservation.id)).to be true
      expect(Db::Reservation.exists?(@cash_prepaid_reservation.id)).to be true
    end

    it 'does not destroy reservations on same day as creation' do
      Timecop.freeze('2016-08-14'.to_date)
      expect {
        Reservations::Unpaid.new.destroy_all
      }.not_to change(Db::Reservation, :count)
    end

    it 'does not destroy reservations after 1 day (need 48 hours)' do
      Timecop.freeze('2016-08-15'.to_date)
      expect {
        Reservations::Unpaid.new.destroy_all
      }.not_to change(Db::Reservation, :count)
    end

    it 'does not destroy reservations after 2 days (need more than 48 hours)' do
      Timecop.freeze('2016-08-16'.to_date)
      expect {
        Reservations::Unpaid.new.destroy_all
      }.not_to change(Db::Reservation, :count)
    end

    it 'destroys unpaid reservations after more than 48 hours (3 days)' do
      expect(Db::Reservation.count).to eq(3)
      
      Timecop.freeze('2016-08-17'.to_date)
      expect {
        Reservations::Unpaid.new.destroy_all
      }.to change(Db::Reservation, :count).from(3).to(2)
      
      # Unpaid reservation should be deleted
      expect(Db::Reservation.exists?(@unpaid_reservation.id)).to be false
      # Paid reservations should remain
      expect(Db::Reservation.exists?(@prepaid_reservation.id)).to be true
      expect(Db::Reservation.exists?(@cash_prepaid_reservation.id)).to be true
    end
  end
end

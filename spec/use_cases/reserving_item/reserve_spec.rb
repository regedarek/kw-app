require 'rails_helper'
require './lib/use_cases/managing_reservations/reserve'
require './lib/use_cases/managing_reservations/cancel'

describe 'managing reservations' do
  let(:booker) { Booker.new(Db::User.new) }

  it 'booker should be able to rent an item' do
    ManagingReservation::Reserve.new(booker, Db::Item.new).perform

    expect(Db::Reservation.count).to eql(1)
  end

  it 'booker should be able to cancel reservation' do
    reservation = Db::Reservation.create!({user: booker.user, item: Db::Item.new})
    ManagingReservation::Cancel.new(reservation).perform

    expect(Db::Reservation.count).to eql(0)
  end

  it 'booker should not be able to reserve already reserved item' do
    item = Db::Item.create!(name: 'Item 1')
    user = Db::User.new(first_name: 'Test First', last_name: 'Test Last', email: 'test@test.pl')
    user.password = '12345678'
    user.save
    booker = Booker.new(user)
    reservation = Db::Reservation.create!(item: item, user: user, start_date: Date.tomorrow, end_date: Date.tomorrow + 1.week)

    expect {
      ManagingReservation::Reserve.new(booker, item).perform(start_date: Date.tomorrow, end_date: Date.tomorrow + 1.week)
    }.not_to change{ Db::Reservation.count }
  end

  it 'booker should not be able to reserve item in the past' do
    item = Db::Item.create!(name: 'Item 1')
    user = Db::User.new(first_name: 'Test First', last_name: 'Test Last', email: 'test@test.pl')
    user.password = '12345678'
    user.save
    booker = Booker.new(user)

    expect {
      ManagingReservation::Reserve.new(booker, item).perform(start_date: Date.yesterday, end_date: Date.yesterday + 1.week)
    }.not_to change{ Db::Reservation.count }
  end

  it 'booker should not be able to reserve item with invalid period' do
    item = Db::Item.create!(name: 'Item 1')
    user = Db::User.new(first_name: 'Test First', last_name: 'Test Last', email: 'test@test.pl')
    user.password = '12345678'
    user.save
    booker = Booker.new(user)

    expect {
      ManagingReservation::Reserve.new(booker, item).perform(start_date: 1.week.from_now, end_date: Date.yesterday)
    }.not_to change{ Db::Reservation.count }
  end
end

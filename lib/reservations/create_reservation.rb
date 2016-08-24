require 'results'
require 'reservations/form'

module Reservations
  class CreateReservation
    def self.from(params:)
      form = Reservations::Form.new(params)
      if form.valid?
        reservation = Db::Reservation.where(start_date: form.params.fetch(:start_date)).first_or_initialize(form.params)
        new_items = Db::Item.where(id: form.params.fetch(:item_ids))
        new_items.each do |item|
          reservation.items.push(item) unless reservation.items.include?(item)
        end

        if reservation.start_date > reservation.end_date
          return Failure.new(:invalid_period, message: 'Data poczatkowa musi byc przed koncowa')
        end

        if Date.today > reservation.start_date || Date.today > reservation.end_date
          return Failure.new(:invalid_period, message: 'Rezerwowac mozna tylko po dzisiejszej dacie')
        end
        
        reservation.save
        ReservationMailer.reserve(reservation).deliver_now
        Success.new
      else
        Failure.new(:invalid, form: form)
      end
    end
  end
end

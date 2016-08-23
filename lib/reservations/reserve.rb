require 'results'
require 'reservations/form'

module Reservations
  class Reserve
    def initialize(allowed_params)
      @allowed_params = allowed_params
    end

    def create
      if form.valid?
        reservation = Db::Reservation.where(start_date: form.params.fetch(:start_date)).first_or_initialize(form.params)
        reservation.items << Db::Item.where(id: form.params.fetch(:item_ids))

        if reservation.start_date > reservation.end_date
          return Failure.new(:invalid_period, message: 'Data poczatkowa musi byc przed koncowa')
        end

        if Date.today > reservation.start_date || Date.today > reservation.end_date
          return Failure.new(:invalid_period, message: 'Rezerwowac mozna tylko po dzisiejszej dacie')
        end
        
        reservation.save
        reservation.reserve!
        ReservationMailer.reserve(reservation).deliver_now
        Success.new
      else
        Failure.new(:invalid, form: form)
      end
    end

    def self.destroy(reservation_id)
      reservation = Db::Reservation.find(reservation_id)
      if reservation.destroy
        Success.new
      else
        Failure.new(:failure)
      end
    end

    def form
      @form ||= Reservations::Form.new(@allowed_params)
    end
  end
end

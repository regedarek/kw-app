require 'results'

module Admin
  class Reservations
    def initialize(allowed_params)
      @allowed_params = allowed_params
    end

    def create
      if form.valid?
        reservation = Db::Reservation.new(form.params)
        reservation.save
        Success.new
      else
        Failure.new(:invalid, form: form)
      end
    end

    def update(reservation_id)
      if form.valid?
        reservation = Db::Reservation.find(reservation_id)
        reservation.update(form.params)
        reservation.save
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
      @form ||= Admin::ReservationsForm.new(@allowed_params)
    end
  end
end

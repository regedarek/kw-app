module Reservations
  class UnpaidReservations
    def self.destroy_after(hours: 24.hours)
      Db::Reservation.where().destroy_all
    end
  end
end

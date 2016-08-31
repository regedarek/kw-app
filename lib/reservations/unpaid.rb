module Reservations
  class Unpaid
    def initialize(after: 48.hours)
      @after = after
    end

    def destroy_all
      Db::Reservation.where('reservations.created_at < ?', 2.day.ago).not_prepaid.destroy_all
    end
  end
end

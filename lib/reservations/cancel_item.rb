module Reservations
  class CancelItem
    def initialize(reservation_id:)
      @reservation_id = reservation_id
    end

    def self.from(reservation_id:)
      new(reservation_id: reservation_id)
    end

    def delete(item_id:)
      return Failure.new(:reservation_not_exist) unless Db::Reservation.exists?(@reservation_id)
      return Failure.new(:item_not_exist) unless Db::Item.exists?(item_id)
      reservation = Db::Reservation.find(@reservation_id)

      reservation.items.delete(Db::Item.find(item_id))
      reservation.destroy if reservation.items.empty?
      Success.new(start_date: reservation.start_date)
    end
  end
end

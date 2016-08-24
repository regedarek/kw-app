module Reservations
  class DeleteItem
    def initialize(reservation_id:)
      @reservation = Db::Reservation.find(reservation_id)
    end

    def self.from(reservation_id:)
      new(reservation_id: reservation_id)
    end

    def delete(item_id:)
      @reservation.items.delete(Db::Item.find(item_id))
      @reservation.destroy if @reservation.items.empty?
      Success.new
    end
  end
end

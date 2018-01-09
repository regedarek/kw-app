module Reservations
  class Unpaid
    def initialize(after: 48.hours)
      @after = after
    end

    def destroy_all
      not_prepaid = Db::Reservation.where('reservations.created_at < ?', 2.day.ago)
                                  .not_prepaid
      prepaid_by_cash = Db::Reservation.where('reservations.created_at < ?', 2.day.ago)
                                       .cash_prepaid
      to_destroy = not_prepaid - prepaid_by_cash
      to_destroy.map(&:destroy)
      Net::HTTP.get(URI('https://hchk.io/8da144aa-7b69-4cb5-bd7e-031c404d5d04'))
    end
  end
end

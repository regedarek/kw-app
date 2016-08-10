module Availability
  class Items
    def initialize(start_date:, end_date: start_date.to_date + 7)
      @start_date = start_date.to_date
      @end_date = end_date.to_date
    end

    def collect
      Db::Item.rentable - not_available_items - Db::Item.instructors
    end

    def week
      @start_date..@end_date
    end

    private

    def not_available_items
      reservations_in_given_week.collect(&:item)
    end

    def reservations_in_given_week
      Db::Reservation.select { |reservation| week.include?(reservation.start_date..reservation.end_date) }  
    end
  end
end

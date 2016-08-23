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
      Db::Reservation.find_by(start_date: @start_date).try(:items) || []
    end
  end
end

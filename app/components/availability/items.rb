module Availability
  class Items
    def initialize(start_date:, end_date: start_date.to_date + 7)
      @start_date = start_date.to_date
      @end_date = end_date.to_date
    end

    def collect
      fail 'start date cannot be in the past' if @start_date.past?
      fail 'start date has to be thursday' unless @start_date.thursday?

      Db::Item.order(:rentable_id).rentable - not_available_items - Db::Item.instructors
    end

    def collect_abc
      collect.select {|i| i.display_name.downcase.match?('abc') }
    end

    def collect_axes
      collect.select {|i| i.display_name.downcase.match?('czekan') }
    end

    def collect_crampons
      collect.select {|i| i.display_name.downcase.match?('raki') }
    end

    def collect_rest
      collect - collect_abc - collect_axes - collect_crampons
    end

    def week
      @start_date..@end_date
    end

    private

    def not_available_items
      Db::Reservation.where(start_date: @start_date, canceled: false).map(&:items).flatten.uniq
    end
  end
end

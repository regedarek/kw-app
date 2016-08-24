require 'date'

module Guards
  class Date
    def initialize(date:)
      @date = date ? date.to_date : Time.zone.today
    end

    def thursday?
      @date.thursday?
    end

    def nearest_thursday
      if @date.thursday?
        @date
      else
        @date.end_of_week(:thursday) + 1
      end
    end
  end
end

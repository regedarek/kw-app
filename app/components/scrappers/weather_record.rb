module Scrappers
  class WeatherRecord < ActiveRecord::Base
    self.table_name = 'weather_records'
  end
end

# == Schema Information
#
# Table name: weather_records
#
#  id             :bigint           not null, primary key
#  all_snow       :float
#  cloud          :integer
#  cloud_url      :string
#  daily_snow     :float
#  place          :string
#  snow_surface   :string
#  snow_type      :integer
#  snow_type_text :string
#  temp           :float
#  wind_direction :integer
#  wind_value     :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
module Scrappers
  class WeatherRecord < ActiveRecord::Base
    self.table_name = 'weather_records'
  end
end

class AddFieldsToWeatherRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :weather_records, :wind_value, :integer
    add_column :weather_records, :wind_direction, :integer
    add_column :weather_records, :cloud, :integer
  end
end

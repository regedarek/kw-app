class AddCloudUrlToWeatherRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :weather_records, :cloud_url, :string
  end
end

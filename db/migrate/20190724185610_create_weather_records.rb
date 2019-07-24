class CreateWeatherRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :weather_records do |t|
      t.string :place
      t.float :temp
      t.float :daily_snow
      t.float :all_snow
      t.integer :snow_type
      t.timestamps
    end
  end
end

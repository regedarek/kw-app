class AddFields2ToWeatherRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :weather_records, :snow_type_text, :string
    add_column :weather_records, :snow_surface, :string
  end
end

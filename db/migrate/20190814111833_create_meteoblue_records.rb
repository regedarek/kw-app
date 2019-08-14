class CreateMeteoblueRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :meteoblue_records do |t|
      t.date :time, null: false
      t.integer :pictocode
      t.float :temperature_max
      t.float :temperature_min
      t.float :temperature_mean
      t.float :felttemperature_max
      t.float :felttemperature_min
      t.integer :winddirection
      t.integer :precipitation_probability
      t.string :rainspot
      t.integer :predictability_class
      t.integer :predictability
      t.float :precipitation
      t.float :snowfraction
      t.integer :sealevelpressure_max
      t.integer :sealevelpressure_min
      t.integer :sealevelpressure_mean
      t.float :windspeed_max
      t.float :windspeed_mean
      t.float :windspeed_min
      t.integer :relativehumidity_max
      t.integer :relativehumidity_min
      t.integer :relativehumidity_mean
      t.float :convective_precipitation
      t.float :precipitation_hours
      t.float :humiditygreater90_hours
      t.timestamps
    end

    add_index :meteoblue_records, :time, unique: true
  end
end

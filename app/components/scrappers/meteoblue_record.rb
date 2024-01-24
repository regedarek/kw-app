# == Schema Information
#
# Table name: meteoblue_records
#
#  id                        :bigint           not null, primary key
#  convective_precipitation  :float
#  felttemperature_max       :float
#  felttemperature_min       :float
#  humiditygreater90_hours   :float
#  location                  :string
#  meteogram                 :string
#  pictocode                 :integer
#  precipitation             :float
#  precipitation_hours       :float
#  precipitation_probability :integer
#  predictability            :integer
#  predictability_class      :integer
#  rainspot                  :string
#  relativehumidity_max      :integer
#  relativehumidity_mean     :integer
#  relativehumidity_min      :integer
#  sealevelpressure_max      :integer
#  sealevelpressure_mean     :integer
#  sealevelpressure_min      :integer
#  snowfraction              :float
#  temperature_max           :float
#  temperature_mean          :float
#  temperature_min           :float
#  time                      :date             not null
#  winddirection             :integer
#  windspeed_max             :float
#  windspeed_mean            :float
#  windspeed_min             :float
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_meteoblue_records_on_time  (time) UNIQUE
#
module Scrappers
  class MeteoblueRecord < ActiveRecord::Base
    self.table_name = 'meteoblue_records'

    mount_uploader :meteogram, MeteoblueUploader
  end
end

module Scrappers
  class MeteoblueUploader < ApplicationUploader
    include CarrierWave::MiniMagick

    version :thumb do
      process resize_to_fill: [180, 180]
    end

    def filename
      "#{model.location.parameterize}-#{model.time.to_date}.png" if original_filename.present?
    end

    def store_dir
      "scrappers/meteoblue/#{model.time.to_date}"
    end
  end
end

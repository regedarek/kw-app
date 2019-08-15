module Scrappers
  class MeteoblueUploader < CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick

    if Rails.env.production? || Rails.env.staging?
      storage :fog
    else
      storage :file
    end

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

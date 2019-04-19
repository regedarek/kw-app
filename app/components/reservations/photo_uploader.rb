module Reservations
  class PhotoUploader < CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick

    if Rails.env.staging?
      storage :fog
    else
      storage :file
    end

    version :thumb do
      process resize_to_fill: [180, 180]
    end

    def store_dir
      "reservations/photos/#{model.id}"
    end
  end
end

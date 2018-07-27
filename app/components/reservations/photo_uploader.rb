module Reservations
  class PhotoUploader < CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick
    storage :file

    version :thumb do
      process resize_to_fill: [180, 180]
    end

    def store_dir
      "uploads/reservations/#{model.id}/#{mounted_as}"
    end
  end
end

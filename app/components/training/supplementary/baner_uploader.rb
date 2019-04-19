module Training
  module Supplementary
    class BanerUploader < CarrierWave::Uploader::Base
      include CarrierWave::MiniMagick
      if Rails.env.production? || Rails.env.staging?
        storage :fog
      else
        storage :file
      end
      process resize_to_limit: [1200, -1]

      def store_dir
        "uploads/courses/#{model.id}/#{mounted_as}"
      end
    end
  end
end

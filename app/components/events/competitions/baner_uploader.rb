module Events
  module Competitions
    class BanerUploader < CarrierWave::Uploader::Base
      include CarrierWave::MiniMagick

      if Rails.env.staging?
        storage :fog
      else
        storage :file
      end

      process resize_to_limit: [1200, -1]

      def store_dir
        "competitions/baners/#{model.id}"
      end
    end
  end
end

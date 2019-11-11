module Scrappers
  class ToprDegreeUploader < CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick

    if Rails.env.production? || Rails.env.staging?
      storage :fog
    else
      storage :file
    end

    def filename
      "#{model.created_at.hour}_00.#{file.extension}" if original_filename.present?
    end

    def store_dir
      "scrappers/topr/#{model.time}"
    end
  end
end

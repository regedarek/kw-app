module Scrappers
  class ImageUploader < ApplicationUploader
    include CarrierWave::MiniMagick

    version :thumb do
      process resize_to_fill: [180, 180]
    end

    def filename
      "#{model.diagram_time.hour}_00.#{file.extension}" if original_filename.present?
    end

    def store_dir
      "scrappers/shmu/#{model.diagram_time.to_date}"
    end
  end
end

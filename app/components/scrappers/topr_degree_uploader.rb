module Scrappers
  class ToprDegreeUploader < CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick

    if Rails.env.production? || Rails.env.staging?
      storage :fog
    else
      storage :file
    end

    version :normal do
      process :efficient_conversion => [200, 68]
    end

    def filename
      "#{model.created_at.hour}_00.jpg" if original_filename.present?
    end

    def store_dir
      "scrappers/topr/#{model.time}"
    end

    private

    def efficient_conversion(width, height)
      manipulate! do |img|
        img.format("jpg").combine_options do |c|
          c.fuzz        "3%"
          c.trim
          c.resize      "#{width}x#{height}>"
          c.resize      "#{width}x#{height}<"
        end
        img
      end
    end
  end
end

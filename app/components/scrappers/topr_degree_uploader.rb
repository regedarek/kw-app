module Scrappers
  class ToprDegreeUploader < CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick
    process :set_content_type

    def set_content_type(*args)
      self.file.instance_variable_set(:@content_type, 'image/jpeg')
    end

    if Rails.env.production? || Rails.env.staging?
      storage :fog
    else
      storage :file
    end

    version :normal do
      process :efficient_conversion => [400, 136]
    end

    version :dashboard do
      process :efficient_conversion => [180, 62]
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
        img.format("png") do |c|
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

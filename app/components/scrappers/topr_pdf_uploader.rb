module Scrappers
  class ToprPdfUploader < CarrierWave::Uploader::Base
    if Rails.env.production? || Rails.env.staging?
      storage :fog
    else
      storage :file
    end

    def filename
      "topr_pdf_#{model.time}.#{file.extension}" if original_filename.present?
    end

    def store_dir
      "scrappers/topr/#{model.time}"
    end
  end
end

module Scrappers
  class ToprPdfUploader < ApplicationUploader

    def filename
      "topr_pdf_#{model.time}.#{file.extension}" if original_filename.present?
    end

    def store_dir
      "scrappers/topr/#{model.time}"
    end
  end
end

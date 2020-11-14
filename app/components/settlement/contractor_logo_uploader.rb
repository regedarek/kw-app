module Settlement
  class ContractorLogoUploader < CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick

    if Rails.env.production? || Rails.env.staging?
      storage :fog
    else
      storage :file
    end

    version :thumb do
      process resize_to_fill: [180, 180]
    end

    def filename
      "#{model.name}.#{file.extension}" if original_filename.present?
    end

    def store_dir
      "contractors/#{model.name}"
    end
  end
end

module PhotoCompetition
  class FileUploader < CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick

    if Rails.env.production? || Rails.env.staging?
      storage :fog
    else
      storage :file
    end

    version :thumb do
      process resize_to_fill: [100, 100]

      def store_dir
        "photo_competitions/#{model.edition.code}/thumbs/#{model.category.name.parameterize.underscore}"
      end
    end

    def store_dir
      "photo_competitions/#{model.edition.code}/#{model.category.name.parameterize.underscore}"
    end
  end
end

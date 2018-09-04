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
        "photo_competitions/#{model.edition.code}/thumbs/#{model.category.name}"
      end

      def filename
        "#{model.edition.code}-#{model.id}-#{model.user.display_name.parameterize.underscore}.#{file.extension}" if original_filename.present?
      end
    end

    def filename
      "#{model.edition.code}-#{model.id}.#{file.extension}" if original_filename.present?
    end

    def store_dir
      "photo_competitions/#{model.edition.code}/#{model.category.name}"
    end
  end
end

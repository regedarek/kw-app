module PhotoCompetition
  class FileUploader < CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick

    if Rails.env.production? || Rails.env.staging?
      storage :fog
    else
      storage :file
    end

    def extension_whitelist
      %w(jpg jpeg png)
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

    def filename
      "#{secure_token}.#{file.extension}" if original_filename.present?
    end

    protected

    def secure_token
      var = :"@#{mounted_as}_secure_token"
      model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
    end
  end
end

module UserManagement
  class PhotoUploader < CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick

    if Rails.env.production? || Rails.env.staging?
      storage :fog
    else
      storage :file
    end

    version :thumb do
      process resize_to_fill: [180, 180]

      def store_dir
      "user_management/profiles/#{model.id}/thumbs"
      end
    end

    def store_dir
      "user_management/profiles/#{model.id}"
    end
  end
end

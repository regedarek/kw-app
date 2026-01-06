module UserManagement
  class PhotoUploader < ApplicationUploader
    include CarrierWave::MiniMagick

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

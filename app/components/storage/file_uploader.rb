module Storage
  class FileUploader < CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick

    if Rails.env.production? || Rails.env.staging?
      storage :fog
    else
      storage :file
    end

    process :auto_orient

    version :thumb do
      process resize_to_fill: [180, 180]
    end

    def store_dir
      "uploads/#{model.uploadable_id}/#{model.uploadable_type}/#{model.id}"
    end

    protected

    def auto_orient
      manipulate! do |image|
        image.tap(&:auto_orient)
      end
    end

    def image?(new_file)
      new_file.content_type.instance_of?(String) && new_file.content_type.start_with?('image')
    end
  end
end

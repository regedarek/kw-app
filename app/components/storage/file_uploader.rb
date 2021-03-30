module Storage
  class FileUploader < CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick
    process :save_content_type_and_size_in_model

    if Rails.env.production? || Rails.env.staging?
      storage :fog
    else
      storage :file
    end

    process :auto_orient

    version :large, :if => :image? do
      process resize_to_fill: [250, 250]
    end

    version :medium, :if => :image? do
      process resize_to_fill: [150, 150]
    end

    version :thumb, :if => :image? do
      process resize_to_fill: [50, 50]
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

    def save_content_type_and_size_in_model
      model.content_type = file.content_type if file.content_type
      model.file_size = file.size
    end

    def image?(new_file)
      return true if model&.content_type&.start_with?('image')

      new_file.content_type.instance_of?(String) && new_file.content_type.start_with?('image')
    end
  end
end

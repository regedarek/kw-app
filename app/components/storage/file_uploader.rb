module Storage
  class FileUploader < ApplicationUploader
    include CarrierWave::MiniMagick
    process :save_content_type_and_size_in_model

    before :cache, :check_mimetype

    process :auto_orient, :if => :image?

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
      # Replace :: with / to create proper directory structure and avoid URL encoding issues
      sanitized_type = model.uploadable_type.gsub('::', '/')
      "uploads/#{model.uploadable_id}/#{sanitized_type}/#{model.id}"
    end

    protected

    def check_mimetype(file)
      if model.content_type.start_with?('image')
        unless allowed_image_mime_types.include? file.content_type
          raise CarrierWave::IntegrityError, 'is an invalid file type'
        end
      end
    end

    def allowed_image_mime_types
      %w(image/jpeg image/jpg image/png image/gif application/pdf)
    end


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
      model.content_type.start_with?('image')
    end
  end
end

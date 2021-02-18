class AttachmentUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  if Rails.env.production? || Rails.env.staging?
    storage :fog
  else
    storage :file
  end

  process :auto_orient

  version :small, :if => :image? do
    process resize_to_fill: [50, 50]
  end

  version :medium, :if => :image? do
    process resize_to_fill: [180, 180]
  end

  def store_dir
    "mountain_routes/attachments/#{model.id}"
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

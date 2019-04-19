module Membership
  class AvatarUploader < CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick

    if Rails.env.staging?
      storage :fog
    else
      storage :file
    end

    process resize_to_limit: [250, 250]

    def store_dir
      "membership/avatars/#{model.id}"
    end
  end
end

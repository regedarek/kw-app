module Membership
  class AvatarUploader < CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick

    if Rails.env.production? || Rails.env.staging?
      storage :fog
    else
      storage :file
    end

    process resize_to_limit: [250, 250]

    def default_url(*args)
      ActionController::Base.helpers.image_url('default-avatar.png')
    end

    def store_dir
      "membership/avatars/#{model.id}"
    end

    # Override fog_public for avatars to avoid signed URL generation and API calls
    # When fog_public is true, CarrierWave uses asset_host directly without checking OpenStack
    def fog_public
      true
    end
  end
end
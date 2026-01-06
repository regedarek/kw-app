# Base uploader class for all CarrierWave uploaders
# Centralizes storage configuration to use cloud storage in production/staging
# or when USE_CLOUD_STORAGE=true in development
class ApplicationUploader < CarrierWave::Uploader::Base
  # Use cloud storage in production/staging, or in development when USE_CLOUD_STORAGE=true
  if Rails.env.production? || Rails.env.staging? || ENV['USE_CLOUD_STORAGE'] == 'true'
    storage :fog
  else
    storage :file
  end
end
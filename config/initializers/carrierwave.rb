require "fog/openstack"

# Helper method to determine if cloud storage should be used
def use_cloud_storage?
  Rails.env.staging? || Rails.env.production? || ENV['USE_CLOUD_STORAGE'].to_s == 'true'
end

if use_cloud_storage?
  CarrierWave.configure do |config|
    config.fog_credentials = {
      provider: 'openstack',
      openstack_api_key: Rails.application.secrets.openstack_api_key,
      openstack_username: Rails.application.secrets.openstack_username,
      openstack_auth_url: "https://auth.cloud.ovh.net/",
      openstack_region: 'WAW',
      connection_options: {
        connect_timeout: 60,
        read_timeout: 60,
        write_timeout: 60,
        persistent: true
      }
    }
    config.asset_host = Rails.application.secrets.openstack_asset_host
    
    # Use staging container in development when USE_CLOUD_STORAGE is enabled
    container_name = if Rails.env.development? && ENV['USE_CLOUD_STORAGE'].to_s == 'true'
                       "kw-app-cloud-staging"
                     else
                       "kw-app-cloud-#{Rails.env}"
                     end
    
    config.fog_directory = container_name
    config.fog_public = false
    
    Rails.logger.info "CarrierWave: Using OpenStack fog storage with container: #{container_name}"
  end
else
  Rails.logger.info "CarrierWave: Using local file storage"
end
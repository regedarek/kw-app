require "fog/openstack"

if Rails.env.staging? || Rails.env.production?
  CarrierWave.configure do |config|
    config.fog_provider = 'fog/openstack'
    config.fog_credentials = {
      provider: 'openstack',
      openstack_api_key: Rails.application.secrets.openstack_api_key,
      openstack_username: Rails.application.secrets.openstack_username,
      openstack_auth_url: "https://auth.cloud.ovh.net/",
      openstack_region: 'WAW',
      connection_options: {
        connect_timeout: 2,
        read_timeout: 2,
        write_timeout: 5,
        persistent: false,
        retry_limit: 0,
        omit_default_port: true
      }
    }
    config.asset_host = Rails.application.secrets.openstack_asset_host
    config.fog_directory = "kw-app-cloud-#{Rails.env}"
    config.fog_public = true
    
    # Use asset_host for URLs instead of making API calls to OpenStack
    config.fog_attributes = {
      'Cache-Control' => 'public, max-age=31536000'
    }
  end
end

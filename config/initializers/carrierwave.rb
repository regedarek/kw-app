require "fog/openstack"

if Rails.env.staging? || Rails.env.production?
  CarrierWave.configure do |config|
    config.fog_provider = 'fog/openstack'
    config.fog_credentials = {
      provider: 'openstack',
      openstack_tenant: Rails.application.secrets.openstack_tenant,
      openstack_api_key: Rails.application.secrets.openstack_api_key,
      openstack_username: Rails.application.secrets.openstack_username,
      openstack_auth_url: "https://auth.cloud.ovh.net:35357/v2.0/tokens",
      openstack_region: 'WAW1'
    }
    config.asset_host = Rails.application.secrets.openstack_asset_host
    config.fog_directory = "kw-app-cloud-#{Rails.env}"
    config.fog_public = false
  end
end

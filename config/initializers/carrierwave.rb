require "fog/openstack"

# Always use cloud storage (OpenStack) for all environments
CarrierWave.configure do |config|
  config.fog_credentials = {
    provider: 'openstack',
    openstack_api_key: Rails.application.credentials.dig(:openstack, :api_key),
    openstack_username: Rails.application.credentials.dig(:openstack, :username),
    openstack_auth_url: "https://auth.cloud.ovh.net/",
    openstack_region: 'WAW',
    connection_options: {
      connect_timeout: 60,
      read_timeout: 60,
      write_timeout: 60,
      persistent: false,
      # Add instrumentation callbacks for debugging
      instrumentor: ActiveSupport::Notifications,
      instrumentor_name: 'excon'
    }
  }
  # Use asset_host from credentials
  config.asset_host = Rails.application.credentials.dig(:openstack, :asset_host)
  
  # Use environment-specific container
  container_name = "kw-app-cloud-#{Rails.env}"
  
  config.fog_directory = container_name
  config.fog_public = false
  
  Rails.logger.info "CarrierWave: Using OpenStack fog storage with container: #{container_name}"
  Rails.logger.info "CarrierWave: persistent=false, timeouts=60s"
end

# Subscribe to Excon events for connection monitoring
ActiveSupport::Notifications.subscribe('excon.request') do |name, start, finish, id, payload|
  duration = ((finish - start) * 1000).round(2)
  if duration > 5000
    Rails.logger.warn "[EXCON] Slow request: #{duration}ms to #{payload[:host]}#{payload[:path]}"
  end
  if payload[:response]
    status = payload[:response][:status]
    if status >= 500
      Rails.logger.error "[EXCON] Server error #{status}: #{payload[:host]}#{payload[:path]}"
    end
  end
end

ActiveSupport::Notifications.subscribe('excon.error') do |name, start, finish, id, payload|
  Rails.logger.error "[EXCON] Connection error: #{payload[:error].class} - #{payload[:error].message}"
  Rails.logger.error "[EXCON] Host: #{payload[:host]}, Path: #{payload[:path]}"
end
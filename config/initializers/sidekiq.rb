if Rails.env.staging?
 #Sidekiq.configure_server do |config|
 #  config.redis = { url: ENV["REDIS_URL"] }
 #end

 #Sidekiq.configure_client do |config|
 #  config.redis = { url: ENV["REDIS_URL"] }
 #end
else
  Sidekiq.configure_server do |config|
    config.redis = { 
      password: ENV.fetch('REDIS_PASSWORD') { Rails.application.credentials.dig(:redis, :password) },
      url: ENV.fetch('REDIS_URL_SIDEKIQ') { Rails.application.credentials.dig(:redis, :url) }
    }
  end

  Sidekiq.configure_client do |config|
    config.redis = { 
      password: ENV.fetch('REDIS_PASSWORD') { Rails.application.credentials.dig(:redis, :password) },
      url: ENV.fetch('REDIS_URL_SIDEKIQ') { Rails.application.credentials.dig(:redis, :url) }
    }
  end
end

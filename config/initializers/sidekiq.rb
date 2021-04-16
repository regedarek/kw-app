if Rails.env.staging?
 #Sidekiq.configure_server do |config|
 #  config.redis = { url: ENV["REDIS_URL"] }
 #end

 #Sidekiq.configure_client do |config|
 #  config.redis = { url: ENV["REDIS_URL"] }
 #end
else
  Sidekiq.configure_server do |config|
    config.redis = { password: ENV.fetch('REDIS_PASSWORD', '+eA8tga96sbquDe9CLL3yUZMNdHM6prSwD6kj1vXO4nzPPudDkxh4U+/LMtOWd+Wd72s9MnXNZqCKZeh'), url: ENV.fetch('REDIS_URL_SIDEKIQ', 'redis://localhost:6379/1') }
  end

  Sidekiq.configure_client do |config|
    config.redis = { password: ENV.fetch('REDIS_PASSWORD', '+eA8tga96sbquDe9CLL3yUZMNdHM6prSwD6kj1vXO4nzPPudDkxh4U+/LMtOWd+Wd72s9MnXNZqCKZeh'), url: ENV.fetch('REDIS_URL_SIDEKIQ', 'redis://localhost:6379/1') }
  end
end

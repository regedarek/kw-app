if Rails.env.staging?
  Sidekiq.configure_server do |config|
    config.redis = { url: 'redis://:p8acf4997e1b39826d2ba0bc71ad9ee34692286831a48c9e3c58c6a8390d48487@ec2-54-196-46-100.compute-1.amazonaws.com:12790' }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: 'redis://:p8acf4997e1b39826d2ba0bc71ad9ee34692286831a48c9e3c58c6a8390d48487@ec2-54-196-46-100.compute-1.amazonaws.com:12790' }
  end
else
  Sidekiq.configure_server do |config|
    config.redis = { password: ENV.fetch('REDIS_PASSWORD', '+eA8tga96sbquDe9CLL3yUZMNdHM6prSwD6kj1vXO4nzPPudDkxh4U+/LMtOWd+Wd72s9MnXNZqCKZeh'), url: ENV.fetch('REDIS_URL_SIDEKIQ', 'redis://localhost:6379/1') }
  end

  Sidekiq.configure_client do |config|
    config.redis = { password: ENV.fetch('REDIS_PASSWORD', '+eA8tga96sbquDe9CLL3yUZMNdHM6prSwD6kj1vXO4nzPPudDkxh4U+/LMtOWd+Wd72s9MnXNZqCKZeh'), url: ENV.fetch('REDIS_URL_SIDEKIQ', 'redis://localhost:6379/1') }
  end
end

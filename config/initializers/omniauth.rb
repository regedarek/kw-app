OmniAuth.config.full_host = 'http://panel.kw.krakow.pl' if Rails.env.production?
OmniAuth.config.full_host = 'http://kw-app-staging.herokuapp.com' if Rails.env.staging?
OmniAuth.config.full_host = 'http://localhost:3000' if Rails.env.development?
OmniAuth.config.full_host = 'http://localhost:3000' if Rails.env.test?

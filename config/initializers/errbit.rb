Airbrake.configure do |config|
  config.host = 'https://kw-app-errbit.herokuapp.com'
  config.project_id = 1 # required, but any positive integer works
  config.project_key = 'f6cbc71e792a4d40269633c80b347361'
  config.environment = Rails.env
  config.ignore_environments = %w(development test)
end

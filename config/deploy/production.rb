server '51.68.141.247', user: 'deploy', roles: %w{app db web}
set :rails_env, :production
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :branch, 'master'
set :default_env, { 'BROWSERSLIST_IGNORE_OLD_DATA' => 'true' }

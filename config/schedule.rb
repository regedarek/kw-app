env :PATH, ENV['PATH']
env :GEM_PATH, ENV['GEM_PATH']
set :output, "cron_log.log"

job_type :rake,    "cd :path && :environment_variable=:environment nice -19 bundle exec rake :task --silent :output"

every 20.minutes do
  rake :send_prepaid_emails
end

every 1.hour do
  rake :destroy_expired_sign_ups
  rake :destroy_expired_events_sign_ups
end

every 6.hours do
  rake :store_topr
end

every '30 4 * * *' do
  rake :send_reminders
end

every '30 6 * * *' do
  rake :destroy_unpaid_reservations
end

every '30 7 * * *' do
  rake :set_regular_members
end

every '30 8 * * *' do
  rake :destroy_outdated_profiles
end

every '0 0 1 3 *' do
  rake :send_yearly_fee_reminder
end

every '0 0 1 9 *' do
  rake :recalculate_cost
end

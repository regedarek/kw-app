env :PATH, ENV['PATH']
env :GEM_PATH, ENV['GEM_PATH']
set :output, "cron_log.log"

every 1.hour do
  rake :destroy_expired_sign_ups
  rake :destroy_expired_events_sign_ups
end

every 24.hours do
  rake :close_outdated_voting
  rake :send_reminders
  rake :send_voting_reminders
  rake :destroy_unpaid_reservations
  rake :set_regular_members
  rake :destroy_outdated_profiles
end

every '0 0 1 3 *' do
  rake :send_yearly_fee_reminder
end

every '0 20 * * *' do
  rake :store_shmu
end

every '0 7 * * *' do
  rake :store_weather
end

every '0 23 * * *' do
  rake :store_meteoblue
end

every '0 0 1 9 *' do
  rake :recalculate_cost
end

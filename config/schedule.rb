env :PATH, ENV['PATH']
env :GEM_PATH, ENV['GEM_PATH']
set :output, "cron_log.log"

every 1.hour do
  rake :destroy_expired_sign_ups
  rake :destroy_expired_events_sign_ups
end

every '30 3 * * *' do
  rake :close_outdated_voting
end

every '30 4 * * *' do
  rake :send_reminders
end

every '30 5 * * *' do
  rake :send_voting_reminders
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

every '45 20 * * *' do
  rake :store_shmu
end

every '40 12 * * *' do
  rake :store_weather
end

every '0 0 1 9 *' do
  rake :recalculate_cost
end

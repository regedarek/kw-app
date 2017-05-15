env :PATH, ENV['PATH']
env :GEM_PATH, ENV['GEM_PATH']
set :output, "cron_log.log"

every 2.minutes do
  rake :test_cron
  rake "send_reminders"
  rake "destroy_unpaid_reservations"
end

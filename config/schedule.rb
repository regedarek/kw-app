env :PATH, ENV['PATH']
env :GEM_PATH, ENV['GEM_PATH']
set :output, "cron_log.log"

every 24.hours do
  rake :send_reminders
  rake :destroy_unpaid_reservations
  rake :set_regular_members
end

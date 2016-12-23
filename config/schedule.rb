set :output, "cron_log.log"

every 24.hours do
  rake "send_reminders"
  rake "destroy_unpaid_reservations"
end

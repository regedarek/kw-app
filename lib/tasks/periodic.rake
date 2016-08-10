desc "This task is called by the Heroku scheduler add-on"

task :send_reminders => :environment do
  Admin::ReservationReminder.send_reminders
end

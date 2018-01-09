desc "This task is called by the Heroku scheduler add-on"

task :send_reminders => :environment do
  Admin::ReservationReminder.send_reminders
end

task :destroy_unpaid_reservations => :environment do
  Reservations::Unpaid.new.destroy_all
end

task :set_regular_members => :environment do
  UserManagement::Members.set_regular
end

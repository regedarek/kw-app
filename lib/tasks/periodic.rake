desc "This task is called by the Heroku scheduler add-on"

task :test_cron => :environment do
  ProfileMailer.apply(Db::Profile.find_by(kw_id: 2345)).deliver_now
end

task :send_reminders => :environment do
  Admin::ReservationReminder.send_reminders
end

task :destroy_unpaid_reservations => :environment do
  Reservations::Unpaid.new.destroy_all
end

task :fetch_events => :environment do
  Events::GoogleAndFacebook.fetch_latest
end

task :set_regular_members => :environment do
  UserManagement::Members.set_regular
end

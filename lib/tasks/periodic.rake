desc "This task is called by the Heroku scheduler add-on"

task :send_reminders => :environment do
  Admin::ReservationReminder.send_reminders
end

task :send_yearly_fee_reminder => :environment do
  Membership::FeesReminderService.new.call
end

task :destroy_unpaid_reservations => :environment do
  Reservations::Unpaid.new.destroy_all
end

task :destroy_outdated_profiles => :environment do
  outdated_profiles = Membership::FeesRepository.new.find_outdated_not_prepaided_profiles
  outdated_profiles.map(&:destroy)
end

task :set_regular_members => :environment do
  UserManagement::Members.set_regular
end

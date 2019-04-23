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

task :destroy_expired_events_sign_ups => :environment do
  expired_sign_ups = Events::Competitions::Repository.new.expired_sign_ups
  expired_sign_ups.each do |sign_up|
    Events::Competitions::SignUps::Destroy.new(
      Events::Competitions::Repository.new
    ).call(id: sign_up.id)
  end
  Net::HTTP.get(URI('https://hc-ping.com/2dce93ef-f5e2-468d-8640-8f27f9233842'))
end

task :destroy_expired_sign_ups => :environment do
  expired_sign_ups = Training::Supplementary::Repository.new.expired_sign_ups
  expired_sign_ups.each do |sign_up|
    Training::Supplementary::DestroySignUp.new(
      Training::Supplementary::Repository.new
    ).call(id: sign_up.id)
  end
  Net::HTTP.get(URI('https://hc-ping.com/3b87fe26-31d5-442d-985b-baa658254ae8'))
end

task :set_regular_members => :environment do
  UserManagement::Members.set_regular
end

task :recalculate_cost => :environment do
  UserManagement::RecalculateCost.new.all
end

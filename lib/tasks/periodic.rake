desc "This task is called by the Heroku scheduler add-on"

task :send_prepaid_emails => :environment do
  Training::Supplementary::SendPrepaidEmail.new.send_prepaid_emails

  Net::HTTP.get(URI('https://hc-ping.com/ddf62dec-b262-49cc-9c1a-d43598be3b28'))
end

task :store_shmu => :environment do
  Scrappers::Shmu.new.call
  Net::HTTP.get(URI('https://hc-ping.com/8a5d9b79-ed79-4270-a6d7-a40d8b90ce64'))
end

task :store_weather => :environment do
  Scrappers::Meteoblue.new.call
  Scrappers::WeatherStorage.new.call
  Scrappers::Topr.new.call
  Net::HTTP.get(URI('https://hc-ping.com/861c60b0-4642-407a-80c3-e629f0ff2c85'))
end

task :send_reminders => :environment do
  Admin::ReservationReminder.send_reminders
end

task :send_voting_reminders => :environment do
  Management::Voting::Reminder.send_reminders
end

task :close_outdated_voting => :environment do
  Management::Voting::Reminder.close_outdated
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
  Net::HTTP.get(URI('https://hc-ping.com/5ddd7a2e-6daa-4a6f-bd99-c97c02d26160'))
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

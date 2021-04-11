require 'net/http'
desc "This task is called by the Heroku scheduler add-on"

task :send_prepaid_emails => :environment do
  Training::Supplementary::SendPrepaidEmail.new.send_prepaid_emails

  Net::HTTP.get(URI('https://hc-ping.com/ddf62dec-b262-49cc-9c1a-d43598be3b28'))
end

task :store_shmu => :environment do
  Scrappers::Shmu.new.call
  Net::HTTP.get(URI('https://hc-ping.com/8a5d9b79-ed79-4270-a6d7-a40d8b90ce64'))
end

task :store_topr => :environment do
  Scrappers::Topr.new.call
  Net::HTTP.get(URI('https://hc-ping.com/d3efda67-730c-418f-870e-15e3ed907e15'))
end

task :store_weather => :environment do
  Scrappers::Meteoblue.new.call
  Scrappers::WeatherStorage.new.call
  Net::HTTP.get(URI('https://hc-ping.com/861c60b0-4642-407a-80c3-e629f0ff2c85'))
end

task :send_reminders => :environment do
  Admin::ReservationReminder.send_reminders
  Net::HTTP.get(URI('https://hchk.io/5e85e1e8-1695-454c-a8cf-f50b8c620417'))
end

task :send_yearly_fee_reminder => :environment do
  Membership::FeesReminderService.new.call
  Net::HTTP.get(URI('https://hc-ping.com/4609aff9-fe10-40b4-9734-04593b8d0f80'))
end

task :destroy_unpaid_reservations => :environment do
  ::Reservations::Workers::DestroyUnpaidReservationsWorker.perform_async
  Net::HTTP.get(URI('https://hchk.io/8da144aa-7b69-4cb5-bd7e-031c404d5d04'))
end

task :destroy_outdated_profiles => :environment do
  ::Membership::Workers::DestroyOutdatedProfilesWorker.perform_async
  Net::HTTP.get(URI('https://hc-ping.com/5ddd7a2e-6daa-4a6f-bd99-c97c02d26160'))
end

task :destroy_expired_events_sign_ups => :environment do
  expired_sign_ups = Events::Competitions::Repository.new.expired_sign_ups
  expired_sign_ups.each do |sign_up|
    Events::Competitions::Worker::DestroyExpiredSignUpWorker.perform_async(sign_up.id)
  end
  Net::HTTP.get(URI('https://hc-ping.com/2dce93ef-f5e2-468d-8640-8f27f9233842'))
end

task :destroy_expired_sign_ups => :environment do
  expired_sign_ups = Training::Supplementary::Repository.new.expired_sign_ups
  expired_sign_ups.each do |sign_up|
    Training::Supplementary::Workers::DestroyExpiredSignUpWorker.perform_async(sign_up.id)
  end
  expired_business_sign_ups = ::Business::Repository.new.expired_sign_ups
  expired_business_sign_ups.each do |sign_up|
    ::Business::Workers::DestroyExpiredSignUpWorker.perform_async(sign_up.id)
  end
  sign_ups_for_equipment = ::Business::Repository.new.sign_ups_for_equipment
  sign_ups_for_equipment.each do |sign_up|
    ::Business::Workers::SendListWorker.perform_async(sign_up.id)
  end
  Net::HTTP.get(URI('https://hc-ping.com/3b87fe26-31d5-442d-985b-baa658254ae8'))
end

task :fill_empty_places => :environment do
  Training::Supplementary::Repository.new.fetch_active_courses.each do |course|
    Training::Supplementary::FillEmptyPlaces.new(
      Training::Supplementary::Repository.new
    ).call(course_id: course.id)
  end
  Net::HTTP.get(URI('https://hc-ping.com/ad0028a1-c2a1-43e7-bb12-6eec68e41f76'))
end

task :set_regular_members => :environment do
  UserManagement::Workers::SetRegularsWorker.perform_async
  Net::HTTP.get(URI('https://hchk.io/83bb1a17-d3ed-4d57-93d5-faa0b8a81021'))
end

task :recalculate_cost => :environment do
  UserManagement::RecalculateCost.new.all
  Net::HTTP.get(URI('https://hc-ping.com/d5a75af7-f362-4595-a736-4df5e8169aaf'))
end

module Membership
  class FeesReminderService
    def call
      kw_ids = Membership::FeesRepository.new.get_unpaid_kw_ids_this_year
      user_emails = Db::User.where(kw_id: kw_ids).map(&:email)
      profile_emails = Db::Profile.where(kw_id: kw_ids).map(&:email)

      emails = user_emails.concat(profile_emails).uniq
      if Rails.env.development?
        Membership::FeesMailer.yearly_reminder(emails).deliver_now
      else
        Membership::FeesMailer.yearly_reminder(emails).deliver_later
      end
    end
  end
end

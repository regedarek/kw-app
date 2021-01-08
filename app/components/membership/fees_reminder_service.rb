module Membership
  class FeesReminderService
    def call
      kw_ids = Membership::FeesRepository.new.get_unpaid_kw_ids_this_year
      profile_emails = Db::Profile.where(kw_id: kw_ids).where.not('position @> array[?]', 'honorable_kw').where.not('position @> array[?]', 'senior').map(&:email)

      Membership::FeesMailer.yearly_reminder(profile_emails).deliver_later
    end
  end
end

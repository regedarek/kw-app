module Membership
  module Admin
    class MembershipFeesController < ::Admin::BaseController
      include EitherMatcher
      append_view_path 'app/components'

      def unpaid
        @profile_unpaid_this_year = Db::Profile
          .where(kw_id: Membership::FeesRepository.new.get_unpaid_kw_ids_this_year)
          .where.not('position @> array[?]', 'honorable_kw').where.not('position @> array[?]', 'senior')
        @profile_unpaid_last_year = Db::Profile
          .where(kw_id: Membership::FeesRepository.new.get_unpaid_kw_ids_last_year)
          .where.not('position @> array[?]', 'honorable_kw').where.not('position @> array[?]', 'senior')
      end

      def check_emails
        @profile_unpaid_this_year = Db::Profile
          .where(kw_id: Membership::FeesRepository.new.get_unpaid_kw_ids_this_year)
          .where.not('position @> array[?]', 'honorable_kw').where.not('position @> array[?]', 'senior')
        @profile_unpaid_last_year = Db::Profile
          .where(kw_id: Membership::FeesRepository.new.get_unpaid_kw_ids_last_year)
          .where.not('position @> array[?]', 'honorable_kw').where.not('position @> array[?]', 'senior')
        emails = extract_emails_to_array(unpaid_params.fetch(:emails, ''))
        unpaid_kw_ids = Membership::FeesRepository.new.find_unpaid_this_year_by_emails(emails)
        @unpaid_emails = Db::Profile.where(kw_id: unpaid_kw_ids).map(&:email).join(' ')
        render :unpaid
      end

      private

      def unpaid_params
        params.require(:unpaid).permit(:emails)
      end

      def extract_emails_to_array(txt)
        reg = /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i
        txt.scan(reg).uniq
      end
    end
  end
end

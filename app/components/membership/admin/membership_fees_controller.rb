module Membership
  module Admin
    class MembershipFeesController < ::Admin::BaseController
      include EitherMatcher
      append_view_path 'app/components'

      def unpaid
        @profile_unpaid_this_year = Db::Profile.where(accepted: true)
          .where.not('position @> array[?]', 'honorable_kw').where.not('position @> array[?]', 'canceled').where.not('position @> array[?]', 'senior').select do |profile|
            !::Membership::Activement.new(user: profile.user).active?
          end
      end

      def check_emails
        @profile_unpaid_this_year = Db::Profile
          .where(kw_id: Membership::FeesRepository.new.get_unpaid_kw_ids_this_year)
          .where.not('position @> array[?]', 'honorable_kw').where.not('position @> array[?]', 'senior').where.not('position @> array[?]', 'canceled')
        @emails = extract_emails_to_array(unpaid_params.fetch(:emails, ''))
        @emails_without_profile = @emails.select { |e| !Db::Profile.exists?(email: e) }
        @unpaid_profiles = Membership::FeesRepository.new.find_unpaid_profiles_this_year_by_emails(@emails).select do |profile|
          !::Membership::Activement.new(user: profile.user).active?
        end
        @unpaid_emails = @unpaid_profiles.map(&:email).join(' ')
        render :unpaid
      end

      private

      def authorize_admin
        redirect_to root_url, alert: 'Nie jestes administratorem!' unless user_signed_in? && (current_user.roles.include?('office') || current_user.admin?)
      end

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

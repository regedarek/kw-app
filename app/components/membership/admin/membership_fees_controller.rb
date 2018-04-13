module Membership
  module Admin
    class MembershipFeesController < ::Admin::BaseController
      include EitherMatcher
      append_view_path 'app/components'

      def unpaid
        @profile_unpaid_this_year = Db::Profile.where(kw_id: Membership::FeesRepository.new.get_unpaid_kw_ids_this_year)
        @profile_unpaid_last_year = Db::Profile.where(kw_id: Membership::FeesRepository.new.get_unpaid_kw_ids_last_year)
      end
    end
  end
end

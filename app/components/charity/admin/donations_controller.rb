module Charity
  module Admin
    class DonationsController < ::Admin::BaseController
      append_view_path 'app/components'
      def index
        return redirect_to root_url, alert: 'Nie masz dostępu!' unless user_signed_in? && (current_user.roles.include?('donations') || current_user.admin?)
        @donations = Charity::DonationRecord.includes(:payment).where(payments: { state: 'prepaid' })
      end
    end
  end
end

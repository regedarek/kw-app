module Charity
  module Admin
    class DonationsController < ::Admin::BaseController
      append_view_path 'app/components'
      def index
        @donations = Charity::DonationRecord.all
      end
    end
  end
end

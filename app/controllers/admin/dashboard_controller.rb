module Admin
	class DashboardController < Admin::BaseController
		def index
		end

    private
    def authorize_admin
      redirect_to root_url, alert: 'Nie jestes administratorem!' unless user_signed_in? && (current_user.roles.include?('office') || current_user.admin?)
    end
	end
end

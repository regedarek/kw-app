module Admin
	class BaseController < ApplicationController
		before_filter :authorize_admin
    layout 'admin'
		
		def authorize_admin
			redirect_to root_url, alert: 'Nie jestes administratorem!' unless user_signed_in? && current_user.admin?
		end
	end
end

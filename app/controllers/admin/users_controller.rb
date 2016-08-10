module Admin
  class UsersController < Admin::BaseController
    def index
      @users = Db::User.order(:kw_id)
    end

    def make_admin
      Db::User.find(params[:id]).update(admin: true)
      redirect_to admin_users_path, notice: 'Awansowales'
    end

    def cancel_admin
      Db::User.find(params[:id]).update(admin: false)
      redirect_to admin_users_path, notice: 'Zdegradowales'
    end
  end
end

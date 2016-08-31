module Admin
  class UsersController < Admin::BaseController
    def index
      @users = Db::User.order(:kw_id).filter(filterable_params)
    end

    def make_admin
      Db::User.find(params[:id]).update(admin: true)
      redirect_to admin_users_path, notice: 'Awansowales'
    end

    def cancel_admin
      Db::User.find(params[:id]).update(admin: false)
      redirect_to admin_users_path, notice: 'Zdegradowales'
    end

    private

    def filterable_params
      params.fetch('admin_users_form', {}).slice(:kw_id, :first_name, :last_name, :email)
    end
  end
end

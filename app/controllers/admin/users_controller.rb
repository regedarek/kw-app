module Admin
  class UsersController < Admin::BaseController
    def index
      @users = Db::User.order(:kw_id).filter(filterable_params).page(params[:page])
    end

    def make_curator
      if Db::User.exists?(curator: true)
        redirect_to admin_users_path, alert: 'Może być tylko jeden władca!'
      else
        user = Db::User.find(params[:id])
        if user.update(curator: true)
          redirect_to admin_users_path, notice: 'Mianowałeś opiekuna'
        else
          redirect_to admin_users_path, alert: user.errors
        end
      end
    end

    def cancel_curator
      Db::User.find(params[:id]).update(curator: false)
      redirect_to admin_users_path, notice: 'No i już nie mamy opiekuna :('
    end

    def make_admin
      Db::User.find(params[:id]).update(admin: true)
      redirect_to admin_users_path, notice: 'Awansowałes'
    end

    def cancel_admin
      Db::User.find(params[:id]).update(admin: false)
      redirect_to admin_users_path, notice: 'Zdegradowałes'
    end

    private

    def filterable_params
      params.fetch('admin_users_form', {}).slice(:kw_id, :first_name, :last_name, :email)
    end
  end
end

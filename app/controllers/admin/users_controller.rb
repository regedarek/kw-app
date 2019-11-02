require 'admin/users_form'

module Admin
  class UsersController < Admin::BaseController
    def index
      authorize! :read, Db::User

      @q = Db::User.includes(:profile, :membership_fees).ransack(params[:q])
      @q.sorts = ['kw_id desc', 'created_at desc'] if @q.sorts.empty?
      @users = @q.result.page(params[:page])
    end

    def edit
      @user = Db::User.friendly.find(params[:id])

      authorize! :read, @user
    end

    def update
      @user = Db::User.friendly.find(params[:id])

      authorize! :update, @user

      roles = user_params.slice(:roles)['roles'].split(' ')
      if @user.update(user_params)
        @user.update roles: roles
        flash[:notice] = 'Zaktualizowano!'
        redirect_to edit_admin_user_path(@user), notice: 'Zaktualizowano'
      else
        render :edit
      end
    end

    def make_curator
      if Db::User.exists?(curator: true)
        redirect_to admin_users_path, alert: 'Może być tylko jeden władca!'
      else
        user = Db::User.friendly.find(params[:id])
        if user.update(curator: true)
          redirect_to admin_users_path, notice: 'Mianowałeś opiekuna'
        else
          redirect_to admin_users_path, alert: user.errors
        end
      end
    end

    def cancel_curator
      Db::User.friendly.find(params[:id]).update(curator: false)
      redirect_to admin_users_path, notice: 'No i już nie mamy opiekuna :('
    end

    def make_admin
      Db::User.friendly.find(params[:id]).update(admin: true)
      redirect_to admin_users_path, notice: 'Awansowałes'
    end

    def cancel_admin
      Db::User.friendly.find(params[:id]).update(admin: false)
      redirect_to admin_users_path, notice: 'Zdegradowałes'
    end

    def become
      return unless current_user.admin?
      bypass_sign_in(Db::User.find(params[:id]))

      redirect_back(fallback_location: root_path)
    end

    private

    def authorize_admin
      redirect_to root_url, alert: 'Nie jestes administratorem!' unless user_signed_in? && (current_user.roles.include?('office') || current_user.admin?)
    end

    def user_params
      params.require(:user).permit(
        :kw_id, :email,:first_name, :last_name, :phone, :roles, :admin, :author_number
      )
    end
  end
end

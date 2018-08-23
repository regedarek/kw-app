class UsersController < ApplicationController
  append_view_path 'app/components'
  def index
    return redirect_to root_path, alert: 'Musisz być zalogowany i aktywny!' unless user_signed_in? && current_user.active?
    @q = Db::User.not_hidden.active.ransack(params[:q])
    @q.sorts = ['kw_id desc', 'created_at desc'] if @q.sorts.empty?
    @users = @q.result.page(params[:page])
  end

  def show
    return redirect_to root_path, alert: 'Musisz być zalogowany i aktywny!' unless user_signed_in? && current_user.active?
    @user = Db::User.find_by(kw_id: params[:kw_id])
  end
end

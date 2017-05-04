module Admin
  class ProfilesController < Admin::BaseController
    def index
      @q = Db::Profile.ransack(params[:q])
      @q.sorts = ['kw_id desc', 'created_at desc'] if @q.sorts.empty?
      @profiles = @q.result.page(params[:page])

      respond_to do |format|
        format.html
        format.xlsx do
          disposition = "attachment; filename='profile_#{Time.now.strftime("%Y-%m-%d-%H%M%S")}.xlsx'"
          response.headers['Content-Disposition'] = disposition
        end
      end
    end

    def show
      @profile = Db::Profile.find(params[:id])
    end

    def accept
      profile = Db::Profile.find(params[:id])
      user = Db::User.new(
        kw_id: profile_params.fetch(:kw_id),
        first_name: profile.first_name,
        last_name: profile.last_name,
        phone: profile.phone,
        email: profile.email
      )
      user.password = SecureRandom.hex(4)
      if user.valid?
        user.save
        profile.update(kw_id: profile_params.fetch(:kw_id), accepted: true)
        user.send_reset_password_instructions

        redirect_to admin_profile_path(profile.id), notice: 'Zaakceptowano'
      else
        redirect_to admin_profile_path(profile.id), alert: "Błąd: #{user.errors.full_messages}"
      end
    end

    private

    def profile_params
      params.require(:profile).permit(:kw_id)
    end
  end
end

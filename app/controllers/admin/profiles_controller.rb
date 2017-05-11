module Admin
  class ProfilesController < Admin::BaseController
    def index
      @q = Db::Profile.ransack(params[:q])
      @q.sorts = ['kw_id desc', 'created_at desc'] if @q.sorts.empty?
      @profiles = @q.result.page(params[:page])
      @profiles = @profiles.where(accepted: false) unless params[:q]

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

    def edit
      @profile = Db::Profile.find(params[:id])
    end

    def update
      @profile = Db::Profile.find(params[:id])

      if @profile.update(profile_params)
        redirect_to edit_admin_profile_path(@profile.id), notice: 'Zaktualizowano'
      else
        render :edit
      end
    end

    def accept
      profile = Db::Profile.find(params[:id])
      user = Db::User.first_or_initialize(kw_id: accept_params.fetch(:kw_id))
      user.first_name = profile.first_name
      user.last_name = profile.last_name
      user.phone = profile.phone
      user.email = profile.email
      user.password = SecureRandom.hex(4)
      if user.valid?
        user.save
        profile.update(
          kw_id: accept_params.fetch(:kw_id),
          application_date: accept_params.fetch(:application_date),
          accepted: true
        )
        user.send_reset_password_instructions

        redirect_to admin_profile_path(profile.id), notice: 'Zaakceptowano'
      else
        redirect_to admin_profile_path(profile.id), alert: "Błąd: #{user.errors.full_messages}"
      end
    end

    private

    def accept_params
      params.require(:profile).permit(:kw_id, :application_date)
    end

    def profile_params
      params.require(:profile).permit(
        :email, :pesel, :first_name, :last_name, :phone, :profession, :application_date,
        :birth_date, :birth_place, :city, :postal_code, :main_address, :date_of_death,
        :optional_address, :main_discussion_group, :terms_of_service, :added, :remarks,
        recommended_by: [], acomplished_courses: [], sections: [], position: []
      )
    end
  end
end

module Admin
  class ProfilesController < Admin::BaseController
    respond_to :html, :xlsx

    def index
      @q = Db::Profile.ransack(params[:q])
      @q.sorts = 'created_at desc' if @q.sorts.empty?
      @profiles = @q.result(distinct: true).page(params[:page])
      @profiles = @profiles.where(accepted: false) unless params[:q]

      respond_with do |format|
        format.html
        format.xlsx do
          @results = @q.result
          disposition = "attachment; filename='profile_#{Time.now.strftime("%Y-%m-%d-%H%M%S")}.xlsx'"
          response.headers['Content-Disposition'] = disposition
        end
      end
    end

    def new
      @profile = Db::Profile.new
    end

    def create
      @profile = Db::Profile.new(profile_params)

      if @profile.save(profile_params)
        flash[:notice] = 'Zaktualizowano!'
        redirect_to admin_profile_path(@profile)
      else
        render :new
      end
    end

    def show
      @profile = Db::Profile.find(params[:id])
      session[:original_referrer] = request.env["HTTP_REFERER"]
    end

    def edit
      @profile = Db::Profile.find(params[:id])
      session[:original_referrer] = request.env["HTTP_REFERER"]
    end

    def update
      @profile = Db::Profile.find(params[:id])

      if @profile.update(profile_params)
        flash[:notice] = 'Zaktualizowano!'
        render :edit
      else
        render :edit
      end
    end

    def send_email
      @profile = Db::Profile.find(params[:id])
      ProfileMailer.apply(@profile).deliver_later

      redirect_to admin_profile_path(@profile.id), notice: 'Wysłano ponownie e-mail zgłoszeniowy!'
    end

    def accept
      profile = Db::Profile.find(params[:id])
      user = Db::User.new
      user.kw_id = accept_params.fetch(:kw_id)
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
          acceptor_id: current_user.id,
          accepted: true
        )
        user.send_reset_password_instructions
        if profile.payment.present? && profile.payment.paid?
          fee = Db::Membership::Fee.create!(
            year: profile.application_date.year,
            kw_id: profile.kw_id,
            payment: profile.payment,
            cost: 100
          )
        end
        ProfileMailer.accepted(profile).deliver_later
        redirect_to admin_profile_path(profile.id), notice: 'Zaakceptowano!'
      else
        redirect_to admin_profile_path(profile.id), alert: "Błąd: #{user.errors.full_messages}"
      end
    end

    private

    def authorize_admin
      redirect_to root_url, alert: 'Nie jestes administratorem!' unless user_signed_in? && (current_user.roles.include?('office') || current_user.admin?)
    end

    def accept_params
      params.require(:profile).permit(:kw_id, :application_date)
    end

    def profile_params
      params.require(:profile).permit(
        :kw_id, :email, :pesel, :first_name, :last_name, :phone, :profession, :application_date,
        :birth_date, :birth_place, :city, :postal_code, :main_address, :date_of_death,
        :optional_address, :main_discussion_group, :terms_of_service, :added, :remarks,
        recommended_by: [], acomplished_courses: [], sections: [], position: []
      )
    end
  end
end

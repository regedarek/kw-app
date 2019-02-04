module Admin
  class ProfilesController < Admin::BaseController
    respond_to :html, :xlsx

    def index
      @q = Db::Profile.ransack(params[:q])
      @q.sorts = 'created_at desc' if @q.sorts.empty?
      @profiles = @q.result(distinct: true).page(params[:page])
      @profiles = @profiles.where(accepted: false) unless params[:q]

      authorize! :read, Db::Profile

      respond_with do |format|
        format.html
        format.xlsx do
          @results = @q.result
          disposition = "attachment; filename='profile_#{Time.now.strftime("%Y-%m-%d-%H%M%S")}.xlsx'"
          response.headers['Content-Disposition'] = disposition
        end
      end
    end

    def general_meeting
      @regulars = Db::Profile.all.select{|p| !p.position.include?('candidate') && !p.position.include?('canceled') }
      @candidates = Db::Profile.where(accepted: true).select{|p| p.position.include?('candidate') && !p.position.include?('canceled') }

      authorize! :read, Db::Profile

      respond_with do |format|
        format.xlsx do
          disposition = "attachment; filename='walne_zebranie_#{Time.now.strftime("%Y-%m-%d-%H%M%S")}.xlsx'"
          response.headers['Content-Disposition'] = disposition
        end
      end
    end

    def new
      @profile = Db::Profile.new
    end

    def create
      @profile = Db::Profile.new(profile_params)
      @profile.acceptor_id = current_user.id

      authorize! :create, Db::Profile

      if @profile.save(profile_params)
        @profile.create_payment(dotpay_id: SecureRandom.hex(13))
        if @profile.accepted
          user = Db::User.new
          user.kw_id = @profile.kw_id
          user.first_name = @profile.first_name
          user.last_name = @profile.last_name
          user.phone = @profile.phone
          user.email = @profile.email
          user.password = SecureRandom.hex(4)
          if user.valid?
            user.save
            user.send_reset_password_instructions
          end
        end
        ProfileMailer.accepted(@profile).deliver_later
        flash[:notice] = 'Dodano użytkownika!'
        redirect_to admin_profile_path(@profile)
      else
        render :new
      end
    end

    def show
      @profile = Db::Profile.find(params[:id])

      authorize! :read, Db::Profile

      session[:original_referrer] = request.env["HTTP_REFERER"]
    end

    def edit
      @profile = Db::Profile.find(params[:id])

      authorize! :manage, Db::Profile

      session[:original_referrer] = request.env["HTTP_REFERER"]
    end

    def update
      @profile = Db::Profile.find(params[:id])

      authorize! :manage, Db::Profile

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
      @profile.update(sent_at: Time.zone.now)

      redirect_to admin_profile_path(@profile.id), notice: 'Wysłano ponownie e-mail zgłoszeniowy!'
    end

    def accept
      profile = Db::Profile.find(params[:id])

      authorize! :manage, Db::Profile

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
            year: Membership::Activement.new.payment_year,
            kw_id: profile.kw_id,
            payment: profile.payment,
            cost: profile.plastic ? 110 : 100,
            plastic: profile.plastic
          )
        end
        ProfileMailer.accepted(profile).deliver_later
        redirect_to admin_profile_path(profile.id), notice: 'Zaakceptowano!'
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
        :kw_id, :email, :pesel, :first_name, :last_name, :phone, :profession, :application_date,
        :birth_date, :birth_place, :city, :postal_code, :main_address, :date_of_death, :cost,
        :optional_address, :main_discussion_group, :terms_of_service, :added, :remarks, :accepted,
        recommended_by: [], acomplished_courses: [], sections: [], position: []
      )
    end
  end
end

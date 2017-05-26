module Mas
  class SignUpsController < ApplicationController
    def index
      @sign_ups = Db::Mas::SignUp.order(:created_at)
    end

    def new
      return redirect_to mas_sign_ups_path, alert: 'Zapisy online zostały zamknięte, możesz jeszcze zapisać się w biurze zawodów na miejscu wpisowe kosztuje 100zł.'
      @form = Mas::SignUpForm.new(
        first_name_1: user_signed_in? ? current_user.first_name : nil,
        last_name_1: user_signed_in? ? current_user.last_name : nil,
        email_1: user_signed_in? ? current_user.email : nil,
        package_type_1: user_signed_in? ? 'kw' : nil,
        kw_id_1: user_signed_in? ? current_user.kw_id : nil,
        organization_1: user_signed_in? ? 'KW Kraków' : nil,
        phone_1: user_signed_in? ? current_user.phone : nil
      )
    end

    def create
      return redirect_to mas_sign_ups_path, alert: 'Zapisy online zostały zamknięte, możesz jeszcze zapisać się w biurze zawodów na miejscu wpisowe kosztuje 100zł.'
      @form = Mas::SignUpForm.new(mas_params)
      result = Mas::Edition2017.sign_up(form: @form)
      result.success { redirect_to mas_sign_ups_path, notice: t('.signed_up') }
      result.invalid { |form:| render(:new) }
      result.error { |errors:| redirect_to mas_sign_ups_path, alert: errors }
      result.else_fail!
    end

    private

    def mas_params
      params
        .require(:mas_sign_up_form)
        .permit(
          :first_name_1, :last_name_1, :birth_year_1, :organization_1, :city_1, :email_1, :package_type_1, :phone_1, :gender_1, :tshirt_size_1,
          :first_name_2, :last_name_2, :birth_year_2, :organization_2, :city_2, :email_2, :package_type_2, :phone_2, :gender_2, :tshirt_size_2,
          :remarks, :terms_of_service, :kw_id_1, :kw_id_2, :name
        )
    end
  end
end

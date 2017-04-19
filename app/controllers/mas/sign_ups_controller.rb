module Mas
  class SignUpsController < ApplicationController
    def index
      @sign_ups = Db::Mas::SignUp.order(:created_at)
    end

    def new
      @sign_up = Db::Mas::SignUp.new
      @form = Mas::SignUpForm.new
    end

    def create
      @form = Mas::SignUpForm.new(mas_params)
      result = Mas::Edition2017.sign_up(form: @form)
      result.success { redirect_to mas_sign_ups_path, notice: t('.signed_up') }
      result.invalid { |form:| render(:new) }
      result.invalid_order { redirect_to mas_sign_ups_path, alert: t('.order_has_not_been_created') }
      result.else_fail!
    end

    private

    def mas_params
      params
        .require(:mas_sign_up_form)
        .permit(
          :name_1, :birth_year_1, :organization_1, :city_1, :email_1, :package_type_1, :phone_1, :gender_1, :tshirt_size_1,
          :name_2, :birth_year_2, :organization_2, :city_2, :email_2, :package_type_2, :phone_2, :gender_2, :tshirt_size_2,
          :remarks, :terms_of_service, :kw_id_1, :kw_id_2
        )
    end
  end
end

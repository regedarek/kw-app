module Strzelecki
  class SignUpsController < ApplicationController
    def index
      @sign_ups = Db::Strzelecki::SignUp.all
    end

    def new
      @sign_up = Db::Strzelecki::SignUp.new
      @form = Strzelecki::SignUpForm.new
    end

    def create
      @form = Strzelecki::SignUpForm.new(strzelecki_params)
      result = Strzelecki::Edition2017.sign_up(form: @form)
      result.success { redirect_to strzelecki_sign_ups_path, notice: t('.signed_up') }
      result.invalid { |form:| render(:new) }
      result.invalid_order { redirect_to strzelecki_sign_ups_path, alert: t('.order_has_not_been_created') }
      result.else_fail!
    end

    private

    def strzelecki_params
      params
        .require(:strzelecki_sign_up_form)
        .permit(
          :name_1, :birth_year_1, :vege_1, :organization_1, :city_1, :email_1, :package_type_1, :phone_1, :gender_1, :tshirt_size_1,
          :name_2, :birth_year_2, :vege_2, :organization_2, :city_2, :email_2, :package_type_2, :phone_2, :gender_2, :tshirt_size_2,
          :single, :remarks, :terms_of_service
        )
    end
  end
end

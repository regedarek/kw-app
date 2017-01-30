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
      result.success { redirect_to strzelecki_sign_ups_path, notice: 'Zapisano. Otrzymasz na podany email informacje jak dokonać płatności.' }
      result.invalid { |form:| render(:new) }
      result.else_fail!
    end

    private

    def strzelecki_params
      params
        .require(:strzelecki_sign_up_form)
        .permit(
          :name_1, :birth_year_1, :vege_1,
          :name_2, :birth_year_2, :vege_2,
          :email, :single, :organization, :category_type, :package_type, :remarks
        )
    end
  end
end

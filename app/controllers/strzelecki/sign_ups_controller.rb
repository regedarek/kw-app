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
      form = Strzelecki::SignUpForm.new(strzelecki_params)
      result = Strzelecki::Edition2017.sign_up(form: form)
      result.success { redirect_to strzelecki_sign_ups_path, notice: 'Zapisano.' }
      result.invalid { |form:| redirect_to strzelecki_sign_ups_path, alert: "Nie dodano z powodu: #{form.errors.messages}" }
      result.else_fail!
    end

    private

    def strzelecki_params
      params.require(:strzelecki_sign_up_form).permit(:names, :email, :team)
    end
  end
end

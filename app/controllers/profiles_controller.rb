require 'results'

class ProfilesController < ApplicationController
  def new
    @profile_form = UserManagement::ProfileForm.new
  end

  def create
    @profile_form = UserManagement::ProfileForm.build_cleaned(profile_params)

    result = UserManagement::UserApplication.create(form: @profile_form, photo: profile_params[:photo])
    result.success { redirect_to root_path, notice: t('.success') }
    result.invalid { |form:| render :new, form: form }
    result.else_fail!
  end

  def show
    @profile = Db::Profile.find(params[:id])
    @filename = "Zgloszenie_#{@profile.first_name}_#{@profile.last_name}.pdf"
    return redirect_to root_path, alert: 'Musisz być administratorem!' unless user_signed_in? && current_user.admin? || current_user.email == @profile.email
  end

  def reactivation
    @reactivation_form = UserManagement::ReactivationForm.new
  end

  def reactivate
    @reactivation_form = UserManagement::ReactivationForm.build_cleaned(profile_params)

    result = UserManagement::Reactivate.call(form: @reactivation_form)
    result.success { redirect_to root_path, notice: t('.success') }
    result.invalid { |form:| render :reactivation, form: @reactivation_form }
    result.else_fail!
  end

  private

  def profile_params
    params.require(:profile).permit(
      :email, :first_name, :last_name, :phone, :plastic, :photo,
      :birth_date, :birth_place, :city, :postal_code, :main_address,
      :optional_address, :main_discussion_group, :terms_of_service,
      recommended_by: [], acomplished_courses: [], sections: []
    )
  end
end

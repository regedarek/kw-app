class ProfilesController < ApplicationController
  def new
    @profile_form = UserManagement::ProfileForm.new
  end

  def create
    @profile_form = UserManagement::ProfileForm.build_cleaned(profile_params)
    
    result = UserManagement::RegisterUser.register(form: @profile_form)
    result.success { redirect_to root_path, notice: t('.success') }
    result.invalid { |form:| render :new, form: form }
    result.invalid_records do |form:, user:, profile:|
      byebug
      render :new, form: form
    end
    result.else_fail!
  end

  private

  def profile_params
    params.require(:profile).permit(
      :email, :kw_id, :pesel, :first_name, :last_name, :phone,
      :birth_date, :birth_place, :city, :postal_code, :main_address,
      :optional_address, :recommended_by, :acomplished_course,
      :main_discussion_group, :sections
    )
  end
end 

class RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(
      :account_update, keys: [:avatar, :hide, :first_name, :last_name, :phone, :email, :kw_id, :password, :password_confirmation, :current_password])
    devise_parameter_sanitizer.permit(
      :sign_up, keys: [:first_name, :last_name, :phone, :email, :kw_id]
    )
  end

  def update_resource(resource, params)
    resource.update_without_password(params)
  end

  def after_update_path_for(resource)
    edit_user_registration_path
  end
end

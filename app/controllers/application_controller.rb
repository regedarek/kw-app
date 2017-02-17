class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale

  protected

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options(options = {})
    { locale: I18n.locale }
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :kw_id, :phone])
    devise_parameter_sanitizer.permit(:sign_in, keys: [:first_name, :last_name, :kw_id, :phone])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :kw_id, :phone])
  end
end

class ApplicationController < ActionController::Base
  include Devise::Controllers::Rememberable
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery prepend: true

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale
  before_action :set_paper_trail_whodunnit

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden, content_type: 'text/html' }
      format.xlsx { redirect_back(fallback_location: main_app.root_path, alert: exception.message) }
      format.html { redirect_back(fallback_location: main_app.root_path, alert: exception.message) }
      format.js   { head :forbidden, content_type: 'text/html' }
    end
  end

    
  protected

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  rescue I18n::InvalidLocale
    I18n.default_locale
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :kw_id, :phone])
    devise_parameter_sanitizer.permit(:sign_in, keys: [:first_name, :last_name, :kw_id, :phone])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :kw_id, :phone])
  end

  def after_sign_in_remember_me(resource)
    remember_me resource
  end
end

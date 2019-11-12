class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden, content_type: 'text/html' }
      format.xlsx { redirect_to main_app.root_url, notice: exception.message }
      format.html { redirect_to main_app.root_url, notice: exception.message }
      format.js   { head :forbidden, content_type: 'text/html' }
    end
  end
  # allow_cors takes in arbitrarily many symbols representing actions that
  # CORS should be enabled for
  def self.allow_cors(*methods)
    before_action :cors_before_filter, :only => methods

    # Rails recommends to use :null_session for APIs
    protect_from_forgery with: :null_session, :only => methods
  end

  def cors_before_filter
    # Check that the `Origin` field matches our front-end client host
    if /\Ahttps?:\/\/localhost:8000\z/ =~ request.headers['Origin']
      headers['Access-Control-Allow-Origin'] = request.headers['Origin']
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
end

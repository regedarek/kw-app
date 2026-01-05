class ApplicationController < ActionController::Base
  include Devise::Controllers::Rememberable
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery prepend: true

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale
  before_action :set_paper_trail_whodunnit
  before_action :ensure_user_loaded

  rescue_from ActiveRecord::RecordNotFound do |exception|
    Appsignal.set_error(exception)
    respond_to do |format|
      format.json { head :not_found, content_type: 'text/html' }
      format.xlsx { redirect_back(fallback_location: main_app.root_path, alert: 'Nie ma takiej strony, sprawdź czy to poprawny adres!') }
      format.html { redirect_back(fallback_location: main_app.root_path, alert: 'Nie ma takiej strony, sprawdź czy to poprawny adres!') }
      format.js   { head :not_found, content_type: 'text/html' }
    end
  end

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

  def ensure_user_loaded
    return unless user_signed_in?
    
    begin
      # Check if current_user is properly loaded
      if current_user.nil?
        Rails.logger.error "ERROR: user_signed_in? is true but current_user is nil"
        sign_out_all_scopes
        return
      end
      
      # Check if kw_id is missing
      if current_user.kw_id.nil?
        Rails.logger.error "ERROR: User #{current_user.id} (#{current_user.email}) has nil kw_id - reloading from database"
        current_user.reload
        
        if current_user.kw_id.nil?
          Rails.logger.error "ERROR: User #{current_user.id} still has nil kw_id after reload - data integrity issue"
        end
      end
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error "ERROR: Session references non-existent user: #{e.message}"
      sign_out_all_scopes
    rescue => e
      Rails.logger.error "ERROR in ensure_user_loaded: #{e.class} - #{e.message}\n#{e.backtrace.first(5).join("\n")}"
    end
  end
end

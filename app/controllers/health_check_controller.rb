class HealthCheckController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!, if: :devise_controller?
  
  rescue_from(Exception) { render plain: 'Service Unavailable', status: :service_unavailable }

  def show
    render plain: 'OK', status: :ok
  end
end

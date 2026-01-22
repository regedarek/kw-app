class HealthCheckController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def show
    render plain: 'OK', status: :ok
  end
end
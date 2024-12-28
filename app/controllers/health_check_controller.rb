class HealthCheckController < ApplicationController
  rescue_from(Exception) { render head: 503, body: 'Service Unavailable' }

  def show
    render head: 200, body: 'OK'
  end
end

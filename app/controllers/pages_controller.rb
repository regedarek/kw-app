class PagesController < ApplicationController
  append_view_path 'app/components'
  include HighVoltage::StaticPage

  before_action :authorize

  def authorize
    if params[:id] == 'wydolnosc'
      if user_signed_in? && Training::Supplementary::SignUpRecord.where(course_id: 213).map(&:user_id).compact.include?(current_user.id)
        puts 'git'
      else
        redirect_to root_path, alert: 'Nie jesteś uczestnikiem KSKS!'
      end
    end
  end
end

class PagesController < ApplicationController
  append_view_path 'app/components'
  include HighVoltage::StaticPage

  before_action :authorize

  def authorize
    if params[:id] == 'gorskie-dziki' || params[:id] == 'narciarskie-dziki'
      if user_signed_in?
        redirect_to root_path, alert: 'Tylko klubowicze z opłaconymi składkami mają dostęp do tabeli!' unless current_user.active?
      else
        redirect_to root_path, alert: 'Tylko klubowicze z opłaconymi składkami mają dostęp do tabeli!'
      end
    end

    if params[:id] == 'wydolnosc'
      if user_signed_in? && Training::Supplementary::SignUpRecord.where(course_id: 213).map(&:user_id).compact.include?(current_user.id)
        puts 'git'
      else
        redirect_to root_path, alert: 'Nie jesteś uczestnikiem KSKS!'
      end
    end

    if params[:id] == 'motoryka'
      if user_signed_in? && Training::Supplementary::SignUpRecord.where(course_id: [214, 215]).map(&:user_id).compact.include?(current_user.id)
        puts 'git'
      else
        redirect_to root_path, alert: 'Nie jesteś uczestnikiem KSKS!'
      end
    end
  end
end

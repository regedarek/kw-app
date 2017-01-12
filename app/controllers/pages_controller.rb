class PagesController < ApplicationController
  include HighVoltage::StaticPage

  layout :layout_for_page

  private

  def layout_for_page
    case params[:id]
    when 'strzelecki'
      'strzelecki'
    else
      if request.env['SERVER_NAME'].include?('strzelecki')
        'strzelecki'
      else
        'application'
      end
    end
  end
end

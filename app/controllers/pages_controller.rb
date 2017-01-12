class PagesController < ApplicationController
  include HighVoltage::StaticPage

  layout :layout_for_page

  private

  def layout_for_page
    return 'strzelecki' if request.env['SERVER_NAME'].include?('strzelecki')

    case params[:id]
    when 'strzelecki'
      'strzelecki'
    else
      'application'
    end
  end
end

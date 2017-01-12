class PagesController < ApplicationController
  include HighVoltage::StaticPage

  layout :layout_for_page

  private

  def layout_for_page
    case params[:id] || request.env['SERVER_NAME'].match('strzelecki')
    when 'strzelecki'
      'strzelecki'
    else
      'application'
    end
  end
end

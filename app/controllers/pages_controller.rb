class PagesController < ApplicationController
  append_view_path 'app/components'
  include HighVoltage::StaticPage
end

module Scrappers
  class ScrappersController < ApplicationController
    append_view_path 'app/components'

    def index
      @diagrams = Scrappers::ShmuRecord.all
    end
  end
end

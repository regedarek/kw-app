module Activities
  class RoutesController < ApplicationController
    include EitherMatcher
    append_view_path 'app/components'

    def index
      @mountain_routes = MountainRouteRecord.page(params[:page]).per(20)
    end
  end
end

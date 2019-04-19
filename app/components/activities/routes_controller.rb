module Activities
  class RoutesController < ApplicationController
    include EitherMatcher
    append_view_path 'app/components'

    def index
      @mountain_routes = MountainRouteRecord.order(climbing_date: :desc).page(params[:page]).per(20)
    end
  end
end

module Training
  module Activities
    module Api
      class MountainRoutesController < ApplicationController
        def index
          mountain_routes = ::Db::Activities::MountainRoute.where(hidden: false)
          mountain_routes = mountain_routes.where(route_type: params[:route_type]) if params[:route_type]
          mountain_routes = mountain_routes.where(training: params[:training]) if params[:training]
          mountain_routes = mountain_routes.order(params[:order] => :desc) if params[:order]

          render json: mountain_routes.limit(5), each_serializer: Training::Activities::Serializers::MountainRouteSerializer
        end
      end
    end
  end
end

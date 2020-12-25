module Training
  module Activities
    module Api
      class MountainRoutesController < ApplicationController
        include Pagy::Backend
        after_action { pagy_headers_merge(@pagy) if @pagy }

        def index
          mountain_routes = ::Db::Activities::MountainRoute.where(hidden: false)
          mountain_routes = mountain_routes.where(route_type: params[:route_type]) if params[:route_type]
          mountain_routes = mountain_routes.where(training: params[:training]) if params[:training]
          mountain_routes = mountain_routes.order(params[:order] => :desc) if params[:order]

          @pagy, records = pagy(mountain_routes)

          render json: records, each_serializer: Training::Activities::Serializers::MountainRouteSerializer
        end
      end
    end
  end
end

module Training
  module Activities
    module Api
      class MountainRoutePointsController < ApplicationController
        def index
          points = Training::Activities::MountainRoutePointRecord.where(mountain_route_id: params[:mountain_route_id])

          render json: points
        end

        def create
          point = Training::Activities::MountainRoutePointRecord.new(point_params)

          if point.valid?
            point.save
            render json: point, status: 201
          else
            render json: point.errors, status: 400
          end
        end

        private

        def point_params
          params.require(:point).permit(:description, :lat, :lng, :mountain_route_id)
        end
      end
    end
  end
end

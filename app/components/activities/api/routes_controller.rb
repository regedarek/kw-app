module Activities
  module Api
    class RoutesController < ApplicationController
      include Pagy::Backend
      after_action { pagy_headers_merge(@pagy) if @pagy }

      def index
        routes = ::Activities::MountainRouteRecord.order(climbing_date: :desc)

        @pagy, records = pagy(routes)

        render json: records, format: :json, each_serializer: Activities::RouteSerializer
      end

      def season
        gender = if params[:gender]
          params[:gender]
        else
          [nil, :male, :female]
        end
        season_leaders = ski_repository.fetch_season(year: params[:id].to_i, gender: gender)

        render json: season_leaders, format: :json, each_serializer: Activities::SeasonLeaderSerializer, year: params[:id]
      end

      def winter
        season_leaders = ski_repository.fetch_winter(year: params[:id].to_i)

        render json: season_leaders, format: :json, each_serializer: Activities::SeasonLeaderSerializer, year: params[:id]
      end

      def spring
        season_leaders = ski_repository.fetch_spring(year: params[:id].to_i)

        render json: season_leaders, format: :json, each_serializer: Activities::SeasonLeaderSerializer, year: params[:id]
      end

      private

      def ski_repository
        @ski_repository ||= SkiRepository.new
      end
    end
  end
end

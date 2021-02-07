module Activities
  module Api
    class RoutesController < ApplicationController
      def season
        season_leaders = ski_repository.fetch_season(year: params[:id].to_i)

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

module Activities
  module Api
    class RoutesController < ApplicationController
      include Pagy::Backend
      after_action { pagy_headers_merge(@pagy) if @pagy }
      append_view_path 'app/components'

      def season
        season_leaders = ski_repository.fetch_season(year: params[:id].to_i)

        @pagy, records = pagy(season_leaders)

        render json: season_leaders, format: :json
      end

      private

      def ski_repository
        @ski_repository ||= SkiRepository.new
      end
    end
  end
end

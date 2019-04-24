module Activities
  class RoutesController < ApplicationController
    include EitherMatcher
    append_view_path 'app/components'

    def gorskie_dziki
      @prev_month_leaders = repository.fetch_prev_month
      @current_month_leaders = repository.fetch_current_month
      @season_leaders = repository.fetch_season
      @best_of_season = repository.best_of_season
      @dziadekgienek = repository.dziadek_gienek
      @tatra_uniqe = repository.tatra_uniqe
    end

    def gorskie_dziki_regulamin; end

    def index
      @mountain_routes = MountainRouteRecord.order(climbing_date: :desc).page(params[:page]).per(20)
    end

    private

    def repository
      @repository ||= Repository.new
    end
  end
end

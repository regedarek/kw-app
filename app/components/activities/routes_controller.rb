module Activities
  class RoutesController < ApplicationController
    include EitherMatcher
    append_view_path 'app/components'

    def gorskie_dziki
      authorize! :read, ::Db::Activities::MountainRoute

      @prev_month_leaders = repository.fetch_prev_month
      @current_month_leaders = repository.fetch_current_month
      @season_leaders = repository.fetch_season
      @best_of_season = repository.best_of_season
      @best_route_of_season = repository.best_route_of_season
      @tatra_uniqe = repository.tatra_uniqe
    end

    def gorskie_dziki_regulamin; end

    def narciarskie_dziki
      authorize! :read, ::Db::Activities::MountainRoute

      @prev_month_leaders = ski_repository.fetch_prev_month
      @current_month_leaders = ski_repository.fetch_current_month
      @season_leaders = ski_repository.fetch_season
      @last_contracts = ski_repository.last_contracts
      @best_of_season = ski_repository.best_of_season
      @best_route_of_season = ski_repository.best_route_of_season
    end

    def narciarskie_dziki_regulamin; end

    def index
      authorize! :read, ::Db::Activities::MountainRoute
      @mountain_routes = MountainRouteRecord.order(climbing_date: :desc).page(params[:page]).per(20)
    end

    private

    def repository
      @repository ||= Repository.new
    end

    def ski_repository
      @ski_repository ||= SkiRepository.new
    end
  end
end

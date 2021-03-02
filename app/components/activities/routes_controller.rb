module Activities
  class RoutesController < ApplicationController
    include EitherMatcher
    append_view_path 'app/components'

    def gorskie_dziki
      authorize! :see_dziki, ::Db::Activities::MountainRoute

      @prev_month_leaders = repository.fetch_prev_month
      @current_month_leaders = repository.fetch_current_month
      @season_leaders = repository.fetch_season
      @best_of_season = repository.best_of_season
      @best_route_of_season = repository.best_route_of_season
      @tatra_uniqe = repository.tatra_uniqe
    end

    def gorskie_dziki_regulamin; end

    def narciarskie_dziki_month
      authorize! :see_dziki, ::Db::Activities::MountainRoute

      @specific_month_leaders = ski_repository.fetch_specific_month_with_gender([nil, :male, :female], params[:year].to_i, params[:month].to_i)
      @specific_month_leaders_male = ski_repository.fetch_specific_month_with_gender([nil, :male], params[:year].to_i, params[:month].to_i)
      @specific_month_leaders_female = ski_repository.fetch_specific_month_with_gender(:female, params[:year].to_i, params[:month].to_i)
    end

    def narciarskie_dziki
      authorize! :see_dziki, ::Db::Activities::MountainRoute

      @prev_prev_month_leaders = ski_repository.fetch_specific_month(2021, Date.today.month - 2)
      @prev_month_leaders = ski_repository.fetch_prev_month
      @current_month_leaders = ski_repository.fetch_current_month
      @season_leaders = ski_repository.fetch_season
      @last_contracts = ski_repository.last_contracts.includes(:contract)
      @my_last_contracts = current_user.training_user_contracts.includes(:route, :contract)
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

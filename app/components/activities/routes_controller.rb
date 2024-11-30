module Activities
  class RoutesController < ApplicationController
    include EitherMatcher
    append_view_path 'app/components'

    def liga_tradowa
      authorize! :see_dziki, ::Db::Activities::MountainRoute

      @season_leaders = Db::User.includes(:mountain_routes).where.not(mountain_routes: { kurtyka_difficulty: nil }).where(mountain_routes: { route_type: 'trad_climbing', climbing_date: Date.today.beginning_of_year..Date.today.end_of_year }).sort_by { |user| -TradLeague::UserSeasonCalculator.new(user: user).call }
    end

    def gorskie_dziki
      authorize! :see_dziki, ::Db::Activities::MountainRoute

      @prev_month_leaders = climbing_repository.fetch_prev_month
      @current_month_leaders = climbing_repository.fetch_current_month
      @season_leaders = climbing_repository.fetch_season
      @best_of_season = climbing_repository.best_of_season
      @best_route_of_season = climbing_repository.best_route_of_season
      @tatra_uniqe = climbing_repository.tatra_uniqe
    end

    def gorskie_dziki_regulamin; end

    def narciarskie_dziki_month
      authorize! :see_dziki, ::Db::Activities::MountainRoute

      @specific_month_leaders = ski_repository.fetch_specific_month_with_gender([nil, :male, :female], params[:year].to_i, params[:month].to_i)
      @specific_month_leaders_male = ski_repository.fetch_specific_month_with_gender([nil, :male], params[:year].to_i, params[:month].to_i)
      @specific_month_leaders_female = ski_repository.fetch_specific_month_with_gender(:female, params[:year].to_i, params[:month].to_i)
    end

    def unhide
      route = ::Db::Activities::MountainRoute.find(params[:id])
      route.update(hidden: false)

      redirect_to activities_mountain_routes_path, notice: 'Opublikowano'
    end

    def narciarskie_dziki
      authorize! :see_dziki, ::Db::Activities::MountainRoute

      @prev_prev_month_leaders = ski_repository.fetch_specific_month(2022, 12)
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

    def climbing_repository
      @climbing_repository ||= ::Activities::ClimbingRepository.new
    end

    def ski_repository
      @ski_repository ||= SkiRepository.new
    end
  end
end

module TradLeague
  class UserSeasonScoresPresenter
    attr_reader :user

    def initialize(user:)
      @user = user
    end

    def call
      {
        points: points,
        routes_count: routes_count,
        hearts_count: hearts_count
      }
    end

    def points
      TradLeague::UserSeasonCalculator.new(user: user).call
    end

    def routes_count
      routes.count
    end

    def hearts_count
      routes.sum(:hearts_count)
    end

    private

    def routes
      Db::Activities::MountainRoute.where(
        user_id: user.id,
        climbing_date: Date.today.beginning_of_year..Date.today.end_of_year,
        route_type: 'trad_climbing'
      ).where.not(kurtyka_difficulty: nil)
    end
  end
end

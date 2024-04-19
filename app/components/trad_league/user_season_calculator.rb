module TradLeague
  class UserSeasonCalculator
    attr_reader :user

    def initialize(user:)
      @user = user
    end

    def call
      routes.inject(0) do |sum, route|
        sum + TradLeague::PointsCalculator.new(route: route).call
      end
    end

    private

    def routes
      Db::Activities::MountainRoute.where(user_id: user.id, climbing_date: Date.today.beginning_of_year..Date.today.end_of_year, route_type: 'trad_climbing').where.not(kurtyka_difficulty: nil)
    end
  end
end

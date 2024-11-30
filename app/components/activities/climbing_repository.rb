module Activities
  class ClimbingRepository
    def fetch_prev_month
      ::Db::User
        .joins(:mountain_routes)
        .where.not(mountain_routes: { id: nil, length: nil, difficulty: excluded_difficulty })
        .where(climbing_boars: true, mountain_routes: { route_type: route_type, climbing_date: Time.now.prev_month.beginning_of_month..Time.now.prev_month.end_of_month, created_at: Time.now.prev_month.beginning_of_month..(Time.now.prev_month.end_of_month + 5.days) })
        .select('users.kw_id, users.id, users.avatar, SUM(mountain_routes.length) AS total_mountain_routes_length')
        .group(:id)
        .order('total_mountain_routes_length DESC')
    end

    def fetch_current_month
      ::Db::User .joins(:mountain_routes) .where.not(mountain_routes: { id: nil, length: nil, difficulty: excluded_difficulty }) .where(climbing_boars: true, mountain_routes: { route_type: route_type, climbing_date: Time.now.beginning_of_month..Time.now.end_of_month, created_at: Time.now.beginning_of_month..(Time.now.end_of_month + 5.days) }) .select('users.kw_id, users.id, users.avatar, SUM(mountain_routes.length) AS total_mountain_routes_length') .group(:id) .order('total_mountain_routes_length DESC')
    end

    def fetch_season
      ::Db::User
        .joins(:mountain_routes)
        .where.not(mountain_routes: { id: nil, length: nil, difficulty: excluded_difficulty })
        .where(climbing_boars: true, mountain_routes: { route_type: route_type, climbing_date: range, created_at: range_created_at })
        .select('users.kw_id, users.id, users.avatar, SUM(mountain_routes.length) AS total_mountain_routes_length')
        .group(:id)
        .order('total_mountain_routes_length DESC')
    end

    def best_route_of_season
      us = ::Db::Activities::MountainRoute
        .where.not(id: nil, length: nil, difficulty: excluded_difficulty)
        .where(route_type: route_type, climbing_date: range, created_at: range)
        .select('id, name, slug, MAX(hearts_count) AS max_mountain_routes_hearts_count')
        .group(:id)
        .order('max_mountain_routes_hearts_count DESC')
    end

    def best_of_season
      us = ::Db::User
        .joins(:mountain_routes)
        .where.not(mountain_routes: { id: nil, length: nil, difficulty: excluded_difficulty })
        .where(climbing_boars: true, mountain_routes: { route_type: route_type, climbing_date: range, created_at: range })
        .select('users.kw_id, users.id, users.avatar, SUM(mountain_routes.hearts_count) AS total_mountain_routes_hearts_count')
        .group(:id)
        .order('total_mountain_routes_hearts_count DESC')
    end

    def respect_for(user)
      user.mountain_routes.where.not(id: nil, length: nil, difficulty: excluded_difficulty).where(route_type: 'regular_climbing', climbing_date: range, created_at: range).sum(:hearts_count)
    end

    def tatra_uniqe
      ::Db::User
        .joins(:mountain_routes)
        .where.not(mountain_routes: { id: nil, length: nil, difficulty: excluded_difficulty })
        .where(climbing_boars: true, mountain_routes: { route_type: route_type, climbing_date: range, created_at: range })
        .where("mountain_routes.description LIKE ?", "%#exploratortatr%").uniq
        .sort_by { |u| u.mountain_routes.where("description LIKE '%#exploratortatr%'").count }.reverse!
    end

    def dziadek_gienek
      ::Db::User
        .joins(:mountain_routes)
        .where.not(mountain_routes: { id: nil, length: nil, difficulty: excluded_difficulty })
        .where(climbing_boars: true, mountain_routes: { route_type: route_type, climbing_date: range, created_at: range_created_at })
        .where("mountain_routes.description LIKE ?", "%#dziadekgienek%").uniq
        .sort_by { |u| u.mountain_routes.where("description LIKE '%#dziadekgienek%'").count }.reverse!
    end

    def start_date
      DateTime.new(2024, 06, 1).beginning_of_day
    end

    def end_date
      DateTime.new(2024, 11, 30).end_of_day
    end

    private

    def route_type
      'regular_climbing'
    end

    def range
      start_date..end_date
    end

    def range_created_at
      start_date..(end_date + 5.days)
    end

    def excluded_difficulty
      [nil, '0', '0+', '0 +', '2', '2+', '2 +', '3', '3+', '3 +', 'I', 'II', 'II+', 'II +', 'III', 'III+', 'III +', '+III']
    end
  end
end

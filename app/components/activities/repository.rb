module Activities
  class Repository
    def fetch_prev_month(route_type = 'regular_climbing')
      range_climbing_date = Time.now.prev_month.beginning_of_month..Time.now.prev_month.end_of_month
      range_created_at = Time.now.prev_month.beginning_of_month..(Time.now.prev_month.end_of_month + 10.days)
      ::Db::User
        .joins(:mountain_routes)
        .where.not(mountain_routes: { id: nil, length: nil })
        .where(climbing_boars: true, mountain_routes: { route_type: route_type, climbing_date: range_climbing_date, created_at: range_created_at })
        .select('users.kw_id, users.id, users.avatar, SUM(mountain_routes.length) AS total_mountain_routes_length')
        .group(:id)
        .order('total_mountain_routes_length DESC')
    end

    def fetch_current_month(route_type = 'regular_climbing')
      range = Time.now.beginning_of_month..Time.now.end_of_month
      ::Db::User
        .joins(:mountain_routes)
        .where.not(mountain_routes: { id: nil, length: nil })
        .where(climbing_boars: true, mountain_routes: { route_type: route_type, climbing_date: range, created_at: range })
        .select('users.kw_id, users.id, users.avatar, SUM(mountain_routes.length) AS total_mountain_routes_length')
        .group(:id)
        .order('total_mountain_routes_length DESC')
    end

    def fetch_season(route_type = 'regular_climbing', start_date=DateTime.new(2020, 06, 1), end_date=DateTime.new(2020, 11, 30))
      range = start_date..end_date
      ::Db::User
        .joins(:mountain_routes)
        .where.not(mountain_routes: { id: nil, length: nil })
        .where(climbing_boars: true, mountain_routes: { route_type: route_type, climbing_date: range, created_at: range })
        .select('users.kw_id, users.id, users.avatar, SUM(mountain_routes.length) AS total_mountain_routes_length')
        .group(:id)
        .order('total_mountain_routes_length DESC')
    end

    def best_route_of_season(route_type = 'regular_climbing')
      range = start_date..end_date
      us = ::Db::User
        .joins(:mountain_routes)
        .where.not(mountain_routes: { id: nil, length: nil })
        .where(climbing_boars: true, mountain_routes: { route_type: route_type, climbing_date: range, created_at: range })
        .select('users.kw_id, users.id, users.avatar, MAX(mountain_routes.hearts_count) AS max_mountain_routes_hearts_count')
        .group(:id)
        .order('max_mountain_routes_hearts_count DESC')
    end

    def best_of_season(route_type = 'regular_climbing')
      range = start_date..end_date
      us = ::Db::User
        .joins(:mountain_routes)
        .where.not(mountain_routes: { id: nil, length: nil })
        .where(climbing_boars: true, mountain_routes: { route_type: route_type, climbing_date: range, created_at: range })
        .select('users.kw_id, users.id, users.avatar, SUM(mountain_routes.hearts_count) AS total_mountain_routes_hearts_count')
        .group(:id)
        .order('total_mountain_routes_hearts_count DESC')
    end

    def tatra_uniqe(route_type = 'regular_climbing')
      range = start_date..end_date
      ::Db::User
        .joins(:mountain_routes)
        .where.not(mountain_routes: { id: nil, length: nil })
        .where(climbing_boars: true, mountain_routes: { route_type: route_type, climbing_date: range, created_at: range })
        .where("mountain_routes.description LIKE ?", "%#exploratortatr%").uniq
        .sort_by { |u| u.mountain_routes.where("description LIKE '%#exploratortatr%'").count }.reverse!
    end

    def dziadek_gienek(route_type = 'regular_climbing')
      range = start_date..end_date
      ::Db::User
        .joins(:mountain_routes)
        .where.not(mountain_routes: { id: nil, length: nil })
        .where(climbing_boars: true, mountain_routes: { route_type: route_type, climbing_date: range, created_at: range })
        .where("mountain_routes.description LIKE ?", "%#dziadekgienek%").uniq
        .sort_by { |u| u.mountain_routes.where("description LIKE '%#dziadekgienek%'").count }.reverse!
    end

    def start_date
      start_date = DateTime.new(2020, 06, 1)
    end

    def end_date
      end_date = DateTime.new(2020, 11, 30)
    end
  end
end

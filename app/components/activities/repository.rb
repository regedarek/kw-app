module Activities
  class Repository
    def fetch_prev_month
      range_climbing_date = Time.now.prev_month.beginning_of_month..Time.now.prev_month.end_of_month
      range_created_at = Time.now.prev_month.beginning_of_month..(Time.now.prev_month.end_of_month + 14.days)
      ::Db::User
        .joins(:mountain_routes)
        .where.not(mountain_routes: { id: nil, length: nil })
        .where(climbing_boars: true, mountain_routes: { route_type: 'regular_climbing', climbing_date: range_climbing_date, created_at: range_created_at })
        .select('users.kw_id, users.id, users.avatar, SUM(mountain_routes.length)')
        .group('users.id')
        .distinct
        .order('SUM(mountain_routes.length) DESC')
    end

    def fetch_current_month
      range = Time.now.beginning_of_month..Time.now.end_of_month
      ::Db::User
        .joins(:mountain_routes)
        .where.not(mountain_routes: { id: nil, length: nil })
        .where(climbing_boars: true, mountain_routes: { route_type: 'regular_climbing', climbing_date: range, created_at: range })
        .select('users.kw_id, users.id, users.avatar, SUM(mountain_routes.length)')
        .group('users.id')
        .distinct
        .order('SUM(mountain_routes.length) DESC')
    end

    def fetch_season
      range = start_date..end_date
      ::Db::User
        .joins(:mountain_routes)
        .where.not(mountain_routes: { id: nil, length: nil })
        .where(climbing_boars: true, mountain_routes: { route_type: 'regular_climbing', climbing_date: range, created_at: range })
        .select('users.kw_id, users.id, users.avatar, SUM(mountain_routes.length)')
        .group('users.id')
        .distinct
        .order('SUM(mountain_routes.length) DESC')
    end

    def best_of_season
      range = start_date..end_date
      us = ::Db::User
        .joins(:mountain_routes)
        .where.not(mountain_routes: { id: nil, length: nil })
        .where(climbing_boars: true, mountain_routes: { route_type: 'regular_climbing', climbing_date: range, created_at: range })
        .select('users.kw_id, users.id, users.avatar, SUM(mountain_routes.hearts_count) AS total_mountain_routes_hearts_count')
        .group('users.id')
        .distinct
        .order('total_mountain_routes_hearts_count DESC')
      # su = users.collect do |user|
      #   { user_id: user.id, mountain_hearts: user.mountain_routes.where(route_type: 'regular_climbing', climbing_date: range, created_at: range).sum(:hearts_count)  }
      # end
    end

    def tatra_uniqe
      range = start_date..end_date
      ::Db::User
        .joins(:mountain_routes)
        .where.not(mountain_routes: { id: nil, length: nil })
        .where(climbing_boars: true, mountain_routes: { route_type: 'regular_climbing', climbing_date: range, created_at: range })
        .where("mountain_routes.description LIKE ?", "%#exploratortatr%").uniq
        .sort_by { |u| u.mountain_routes.where("description LIKE '%#exploratortatr%'").count }.reverse!
    end

    def dziadek_gienek
      range = start_date..end_date
      ::Db::User
        .joins(:mountain_routes)
        .where.not(mountain_routes: { id: nil, length: nil })
        .where(climbing_boars: true, mountain_routes: { route_type: 'regular_climbing', climbing_date: range, created_at: range })
        .where("mountain_routes.description LIKE ?", "%#dziadekgienek%").uniq
        .sort_by { |u| u.mountain_routes.where("description LIKE '%#dziadekgienek%'").count }.reverse!
    end

    def start_date
      start_date = DateTime.new(2019, 05, 1)
    end

    def end_date
      end_date = DateTime.new(2019, 12, 15)
    end
  end
end

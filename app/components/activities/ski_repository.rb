module Activities
  class SkiRepository
    def last_contracts
      Training::Activities::UserContractRecord.includes(:route).order(created_at: :desc).limit(5)
    end

    def fetch_prev_month
      range_climbing_date = Time.now.prev_month.beginning_of_month..Time.now.prev_month.end_of_month
      range_created_at = Time.now.prev_month.beginning_of_month..(Time.now.prev_month.end_of_month + 3.days)
      ::Db::User
        .joins(:mountain_routes)
        .where.not(mountain_routes: { id: nil, length: nil })
        .where(boars: true, mountain_routes: { route_type: route_type, climbing_date: range_climbing_date, created_at: range_created_at })
        .select('users.kw_id, users.id, users.avatar, SUM(mountain_routes.boar_length) AS total_mountain_routes_length')
        .group(:id)
        .order('total_mountain_routes_length DESC')
    end

    def fetch_specific_month(year, month)
      if year && month
        specific_date = Date.new(year, month, 01)
      else
        specific_date = Date.today
      end
      range = specific_date.beginning_of_month..specific_date.end_of_month
      range_created_at = specific_date.beginning_of_month..(specific_date.end_of_month + 3.days)
      ::Db::User
        .joins(:mountain_routes)
        .where.not(mountain_routes: { id: nil, length: nil })
        .where(boars: true, mountain_routes: { route_type: route_type, climbing_date: range, created_at: range_created_at })
        .select('users.kw_id, users.id, users.first_name, users.last_name, users.avatar, SUM(mountain_routes.boar_length) AS total_mountain_routes_length')
        .group(:id)
        .order('total_mountain_routes_length DESC')
    end

    def fetch_current_month
      range = Time.now.beginning_of_month..Time.now.end_of_month
      ::Db::User
        .joins(:mountain_routes)
        .where.not(mountain_routes: { id: nil, length: nil })
        .where(boars: true, mountain_routes: { route_type: route_type, climbing_date: range, created_at: range })
        .select('users.kw_id, users.id, users.first_name, users.last_name, users.avatar, SUM(mountain_routes.boar_length) AS total_mountain_routes_length')
        .group(:id)
        .order('total_mountain_routes_length DESC')
    end

    def fetch_season(year: Date.today.year)
      start_day = DateTime.new(year - 1, 12, 01)
      end_day = DateTime.new(year, 4, 30)
      range = start_day..end_day
      ::Db::User
        .joins(:mountain_routes)
        .where.not(mountain_routes: { id: nil, length: nil })
        .where(boars: true, mountain_routes: { route_type: route_type, climbing_date: range, created_at: range })
        .select('users.kw_id, users.id, users.avatar, SUM(mountain_routes.boar_length) AS total_mountain_routes_length')
        .group(:id)
    end

    def fetch_winter(year: Date.today.year)
      start_day = DateTime.new(year - 1, 12, 01)
      range_climbing_date = start_day..DateTime.new(year, 2, 28)
      range_created_at = start_day..(DateTime.new(year, 2, 28) + 3.days)
      ::Db::User
        .joins(:mountain_routes)
        .where.not(mountain_routes: { id: nil, length: nil })
        .where(boars: true, mountain_routes: { route_type: route_type, climbing_date: range_climbing_date, created_at: range_created_at })
        .select('users.kw_id, users.id, users.avatar, SUM(mountain_routes.boar_length) AS total_mountain_routes_length')
        .group(:id)
    end

    def fetch_spring(year: Date.today.year)
      end_day = DateTime.new(year, 4, 30)
      range_climbing_date = DateTime.new(year, 3, 1)..end_day
      range_created_at = DateTime.new(year, 3, 1)..(end_day + 3.days)
      ::Db::User
        .joins(:mountain_routes)
        .where.not(mountain_routes: { id: nil, length: nil })
        .where(boars: true, mountain_routes: { route_type: route_type, climbing_date: range_climbing_date, created_at: range_created_at })
        .select('users.kw_id, users.id, users.avatar, SUM(mountain_routes.boar_length) AS total_mountain_routes_length')
        .group(:id)
    end

    def best_route_of_season
      range = start_date..end_date
      us = ::Db::User
        .joins(:mountain_routes)
        .where.not(mountain_routes: { id: nil, length: nil })
        .where(boars: true, mountain_routes: { route_type: route_type, climbing_date: range, created_at: range })
        .select('users.kw_id, users.id, users.avatar, MAX(mountain_routes.hearts_count) AS max_mountain_routes_hearts_count')
        .group(:id)
        .order('max_mountain_routes_hearts_count DESC')
    end

    def best_of_season
      range = start_date..end_date
      us = ::Db::User
        .joins(:mountain_routes)
        .where.not(mountain_routes: { id: nil, length: nil })
        .where(boars: true, mountain_routes: { route_type: route_type, climbing_date: range, created_at: range })
        .select('users.kw_id, users.id, users.avatar, SUM(mountain_routes.hearts_count) AS total_mountain_routes_hearts_count')
        .group(:id)
        .order('total_mountain_routes_hearts_count DESC')
    end

    def start_date
      DateTime.new(2020, 12, 01)
    end

    def end_date
      DateTime.new(2021, 4, 30)
    end

    private

    def route_type
      'ski'
    end
  end
end

module Activities
  class SkiRepository
    def last_contracts
      Training::Activities::UserContractRecord.includes(:contract, :route).order(created_at: :desc).limit(5)
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

    def fetch_current_month
      range = Time.now.beginning_of_month..Time.now.end_of_month
      ::Db::User
        .joins(:mountain_routes)
        .where.not(mountain_routes: { id: nil, length: nil })
        .where(boars: true, mountain_routes: { route_type: route_type, climbing_date: range, created_at: range })
        .select('users.kw_id, users.id, users.avatar, SUM(mountain_routes.boar_length) AS total_mountain_routes_length')
        .group(:id)
        .order('total_mountain_routes_length DESC')
    end

    def fetch_season
      range = start_date..end_date
      ::Db::User
        .joins(:mountain_routes)
        .where.not(mountain_routes: { id: nil, length: nil })
        .where(boars: true, mountain_routes: { route_type: route_type, climbing_date: range, created_at: range })
        .select('users.kw_id, users.id, users.avatar, SUM(mountain_routes.boar_length) AS total_mountain_routes_length')
        .group(:id)
        .order('total_mountain_routes_length DESC')
    end

    def fetch_winter
      range_climbing_date = start_date..DateTime.new(2021, 2, 28)
      range_created_at = start_date..(DateTime.new(2021, 2, 28) + 3.days)
      ::Db::User
        .joins(:mountain_routes)
        .where.not(mountain_routes: { id: nil, length: nil })
        .where(boars: true, mountain_routes: { route_type: route_type, climbing_date: range_climbing_date, created_at: range_created_at })
        .select('users.kw_id, users.id, users.avatar, SUM(mountain_routes.boar_length AS total_mountain_routes_length')
        .group(:id)
        .order('total_mountain_routes_length DESC')
    end

    def fetch_spring
      range_climbing_date = DateTime.new(2021, 3, 1)..end_date
      range_created_at = DateTime.new(2021, 3, 1)..(end_date + 3.days)
      ::Db::User
        .joins(:mountain_routes)
        .where.not(mountain_routes: { id: nil, length: nil })
        .where(boars: true, mountain_routes: { route_type: route_type, climbing_date: range_climbing_date, created_at: range_created_at })
        .select('users.kw_id, users.id, users.avatar, SUM(mountain_routes.boar_length) AS total_mountain_routes_length')
        .group(:id)
        .order('total_mountain_routes_length DESC')
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

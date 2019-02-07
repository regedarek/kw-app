module Training
  module Activities
    class Repository
      def create(form_outputs:, user_id:)
        record = ::Db::Activities::MountainRoute
          .create!(form_outputs.to_h)
        record.update(user_id: user_id)

        Training::Activities::SkiRoute.from_record(record)
      end

      def choose_winer_from_last_month
        range = Time.now.prev_month.beginning_of_month..Time.now.prev_month.end_of_month
        routes = ::Db::Activities::MountainRoute
          .where(
            route_type: 'ski',
            climbing_date: range,
            created_at: Time.now.prev_month.beginning_of_month..(Time.now.prev_month.end_of_month + 2.days)
        ).select {|r| r.attachments.any? }
        users_ids = routes.collect(&:colleagues).flatten.map(&:id)
        users = ::Db::User.where(id: users_ids, boars: true)
        users.sample
      end

      def fetch_prev_prev_month
        range_climbing_date = Time.now.prev_month.beginning_of_month..Time.now.prev_month.end_of_month
        range_created_at = Time.now.prev_month.beginning_of_month..(Time.now.prev_month.end_of_month + 2.days)
        ::Db::User
          .joins(:mountain_routes)
          .where.not(mountain_routes: { id: nil, length: nil })
          .where(mountain_routes: { route_type: 'ski', climbing_date: range_climbing_date, created_at: range_created_at })
          .select('users.id, SUM(mountain_routes.length)')
          .group('users.id')
          .distinct
          .order('SUM(mountain_routes.length) DESC')
      end

      def fetch_prev_month
        range_climbing_date = Time.now.prev_month.beginning_of_month..Time.now.prev_month.end_of_month
        range_created_at = Time.now.prev_month.beginning_of_month..(Time.now.prev_month.end_of_month + 2.days)
        routes = ::Db::Activities::MountainRoute
          .where(route_type: 'ski', climbing_date: range_climbing_date, created_at: range_created_at).distinct
        users_ids = routes.collect(&:colleagues).flatten.uniq.map(&:id)
        users = ::Db::User.where(id: users_ids, boars: true)

        hash = Hash.new
        users.each do |user|
          user_routes = routes.select do |route|
            route.colleagues.include?(user)
          end
          hash[user.display_name] = user_routes.map(&:length).compact.sum
        end
        hash.sort_by {|_key, value| value}.reverse
      end

      def fetch_current_month
        range = Time.now.beginning_of_month..Time.now.end_of_month
        routes = ::Db::Activities::MountainRoute
          .where(
            route_type: 'ski',
            climbing_date: range,
            created_at: range
        ).uniq
        users_ids = routes.collect(&:colleagues).flatten.uniq.map(&:id)
        users = ::Db::User.where(id: users_ids, boars: true)

        hash = Hash.new
        users.each do |user|
          user_routes = routes.select do |route|
            route.colleagues.include?(user)
          end
          hash[user.display_name] = user_routes.map(&:length).compact.sum
        end
        hash.sort_by {|_key, value| value}.reverse
      end

      def fetch_season
        range = start_date..end_date
        routes = ::Db::Activities::MountainRoute
          .where(
            route_type: 'ski',
            climbing_date: range,
            created_at: range
        ).uniq
        users_ids = routes.collect(&:colleagues).flatten.uniq.map(&:id)
        users = ::Db::User.where(id: users_ids, boars: true)

        hash = Hash.new
        users.each do |user|
          user_routes = routes.select do |route|
            route.colleagues.include?(user)
          end
          hash[user.display_name] = user_routes.map(&:length).compact.sum
        end
        hash.sort_by {|_key, value| value}.reverse
      end

      def start_date
        start_date = DateTime.new(2018, 11, 1)
      end

      def end_date
        end_date = DateTime.new(2019, 5, 1)
      end
    end
  end
end

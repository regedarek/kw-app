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
            created_at: Time.now.prev_month.beginning_of_month..(Time.now.prev_month.end_of_month + 6.days)
        ).select {|r| r.attachments.any? }
        users_ids = routes.collect(&:colleagues).flatten.map(&:id)
        users = ::Db::User.where(id: users_ids, boars: true)
        users.sample
      end

      def fetch_prev_month
        range = Time.now.prev_month.beginning_of_month..Time.now.prev_month.end_of_month
        routes = ::Db::Activities::MountainRoute
          .where(
            route_type: 'ski',
            climbing_date: range,
            created_at: Time.now.prev_month.beginning_of_month..(Time.now.prev_month.end_of_month + 6.days)
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

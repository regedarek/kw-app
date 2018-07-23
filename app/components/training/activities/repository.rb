module Training
  module Activities
    class Repository
      def create(form_outputs:)
        record = ::Db::Activities::MountainRoute
          .create!(form_outputs.to_h)

        Training::Activities::SkiRoute.from_record(record)
      end

      def fetch_prev_month
        range = Time.now.prev_month.beginning_of_month..Time.now.prev_month.end_of_month
        routes = ::Db::Activities::MountainRoute
          .where(
            route_type: 'ski',
            climbing_date: range,
            created_at: range
        ).uniq
        users = routes.collect(&:colleagues).flatten.uniq

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
        users = routes.collect(&:colleagues).flatten.uniq

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
        start_date = if Date.today.month >= 6 && Date.today.month < 11
                      DateTime.new(Date.today.year - 1, 11, 1)
                     else
                      DateTime.new(Date.today.year, 11, 1)
                     end
        end_date = if Date.today.month >= 6 && Date.today.month < 11
                      DateTime.new(Date.today.year, 11, 1)
                     else
                      DateTime.new(Date.today.year + 1, 11, 1)
                     end
        range = start_date..end_date
        routes = ::Db::Activities::MountainRoute
          .where(
            route_type: 'ski',
            climbing_date: range,
            created_at: range
        ).uniq
        users = routes.collect(&:colleagues).flatten.uniq

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
        start_date = if Date.today.month >= 6 && Date.today.month < 11
                      DateTime.new(Date.today.year - 1, 11, 1)
                     else
                      DateTime.new(Date.today.year, 11, 1)
                     end
      end

      def end_date
        end_date = if Date.today.month >= 6 && Date.today.month < 11
                      DateTime.new(Date.today.year, 11, 1)
                     else
                      DateTime.new(Date.today.year + 1, 11, 1)
                     end
      end
    end
  end
end

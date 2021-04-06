module Membership
  module Card
    class Repository
      def fetch_mountain_routes(user)
        routes = Db::Activities::RouteColleagues.includes(:mountain_route).where(colleague_id: user.id).map(&:mountain_route).compact
        my_routes = user.mountain_routes.includes(:photos).where(hidden: false).includes(:colleagues) + Db::Activities::MountainRoute.where(id: routes.map(&:id), hidden: false)
        my_routes.uniq.sort_by(&:climbing_date).reverse!
      end

      def fetch_courses(user)
        Training::Supplementary::SignUpRecord
          .includes(:course)
          .where(user_id: user.id)
          .order(created_at: :desc)
          .collect(&:course)
          .compact
      end

      def fetch_projects(user)
        Management::ProjectRecord.includes(:users, :project_users).where(users: { id: user.id })
      end
    end
  end
end

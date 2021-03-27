module Training
  module Activities
    class StravaFetcher
      def activities(user:, per_page: 30, page: 1)
        activities = []
        client(user.strava_token).athlete_activities(per_page: per_page, page: page) do |activity|
          activities << {
            name: activity.name,
            strava_url: activity.strava_url,
            id: activity.id
          } if !user.mountain_routes.exists?(strava_id: activity.id) && our_type(activity.type)
        end
        activities
      end

      def activity(user:, strava_id:)
        client(user.strava_token).activity(strava_id)
      end

      private

      def our_type(strava_type)
        {
          "BackcountrySki" => :ski,
          "NordicSki" => :ski,
          "RockClimbing" => :regular_climbing
        }.fetch(strava_type, false)
      end

      def client(token)
        Strava::Api::Client.new(access_token: token)
      end
    end
  end
end

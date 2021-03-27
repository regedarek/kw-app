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
          }
        end
        activities
      end

      private

      def client(token)
        Strava::Api::Client.new(access_token: token)
      end
    end
  end
end

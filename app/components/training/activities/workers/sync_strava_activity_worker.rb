module Training
  module Activities
    module Workers
      class SyncStravaActivityWorker
        include Sidekiq::Worker

        def perform(user_id, strava_id, name)
          user = ::Db::User.find(user_id)
          activity = strava_fetcher.activity(user: user, strava_id: strava_id)

          return false if !our_type(activity.type) || user.mountain_routes.exists?(strava_id: activity.id)

          route = user.mountain_routes.create(
            strava_id: activity.id,
            user_id: user.id,
            map_summary_polyline: activity.map.summary_polyline,
            name: name || activity.name,
            hidden: true,
            time: activity.moving_time_in_hours_s,
            distance: activity.distance_in_kilometers,
            route_type: our_type(activity.type),
            description: activity.description,
            climbing_date: activity.start_date,
            length: activity.total_elevation_gain_in_meters,
            rating: 2
          )
          route.photos.create(remote_file_url: activity.photos.primary.urls['600']) if activity.photos.count >= 1
        end

        def strava_fetcher
          ::Training::Activities::StravaFetcher.new
        end

        def our_type(strava_type)
          {
            "BackcountrySki" => :ski,
            "NordicSki" => :ski,
            "RockClimbing" => :regular_climbing
          }.fetch(strava_type, false)
        end
      end
    end
  end
end

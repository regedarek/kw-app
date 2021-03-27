module Training
  module Activities
    module Api
      class StravaActivitiesController < ApplicationController
        def index
          activities = strava_fetcher.activities(
            user: Db::User.find(params[:user_id]),
            per_page: params[:per_page] || 30,
            page: params[:page] || 1
          )

          render json: activities.as_json
        end

        def create
          user = Db::User.find(params[:user_id])

          activity = strava_fetcher.activity(user: user, strava_id: params[:strava_id])

          return false if our_type(activity.type) && !user.mountain_routes.exists?(strava_id: activity.id)
          route = user.mountain_routes.create(
            strava_id: activity.id,
            map_summary_polyline: activity.map.summary_polyline,
            name: activity.name,
            route_type: our_type(activity.type),
            description: activity.description,
            climbing_date: activity.start_date,
            length: activity.total_elevation_gain,
            rating: 2
          )
          route.photos.create(remote_file_url: activity.photos.primary.urls['600']) if activity.photos.count >= 1

          if route
            render json: route, status: :created
          else
            render json: activity.as_json, status: 400
          end
        end

        def our_type(strava_type)
          {
            "BackcountrySki" => :ski,
            "NordicSki" => :ski,
            "RockClimbing" => :regular_climbing
          }.fetch(strava_type, false)
        end

        def strava_fetcher
          ::Training::Activities::StravaFetcher.new
        end
      end
    end
  end
end

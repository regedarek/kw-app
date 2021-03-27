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

          map = activity.map

          route = user.mountain_routes.create(
            strava_id: activity.id,
            name: activity.name,
            route_type: our_type(activity.type),
            description: activity.description,
            climbing_date: activity.start_date,
            length: activity.total_elevation_gain,
            rating: 2
          ) if our_type(activity.type) && !user.mountain_routes.exists?(strava_id: activity.id)

          if route
            render json: route, status: :created
          else
            render json: activity.as_json, status: 400
          end
        end

        private

        def google_image_url(map)
          decoded_summary_polyline = Polylines::Decoder.decode_polyline(map.summary_polyline)
          start_latlng = decoded_summary_polyline[0]
          end_latlng = decoded_summary_polyline[-1]

          google_maps_api_key = ENV['GOOGLE_STATIC_MAPS_API_KEY']

          "https://maps.googleapis.com/maps/api/staticmap?maptype=roadmap&path=enc:#{map.summary_polyline}&key=#{google_maps_api_key}&size=800x800&markers=color:yellow|label:S|#{start_latlng[0]},#{start_latlng[1]}&markers=color:green|label:F|#{end_latlng[0]},#{end_latlng[1]}"
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

module Training
  module Activities
    module Api
      class StravaActivitiesController < ApplicationController
        def index
          activities = strava_fetcher.activities(
            user: ::Db::User.find(params[:user_id]),
            per_page: params[:per_page] || 30,
            page: params[:page] || 1
          )

          render json: activities.as_json
        end

        def create
          if params[:user_id] && params[:strava_id]
            ::Training::Activities::Workers::SyncStravaActivityWorker
              .perform_async(user_id: params[:user_id], strava_id: params[:strava_id], name: params[:name])
            render json: {message: 'Zakolejkowano!'}, status: :created
          else
            render json: {}, status: 400
          end
        end

        def subscribe
          challenge = ::Strava::Webhooks::Models::Challenge.new(params.permit(:"hub.challenge", :"hub.mode", :"hub.verify_token"))
          raise 'Bad Request' unless challenge.verify_token == 'strava_token'

          render json: challenge.response, status: 200
        end

        def callback
          event = ::Strava::Webhooks::Models::Event.new(event_params)
          user = ::Db::User.find_by(strava_athlete_id: event_params[:owner_id])

          if event.aspect_type == 'create' && event.object_type == 'activity'
            ::Training::Activities::Workers::SyncStravaActivityWorker
              .perform_async(user_id: user.id, strava_id: event_params[:object_id]) if user && event_params[:object_id]
          end

          render json: { ok: true }, status: :ok
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

        def event_params
          params.permit(:aspect_type, :event_time, :object_id, :object_type, :owner_id, :subscription_id)
        end
      end
    end
  end
end

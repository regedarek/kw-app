module Training
  module Activities
    class StravaController < ApplicationController
      append_view_path 'app/components'

      def index
        authorize! :create, ::Db::Activities::MountainRoute
      end

      def new
        authorize! :create, ::Db::Activities::MountainRoute

        return redirect_to '/activities/strava' if current_user.strava_token

        if current_user.strava_client_id.present? && current_user.strava_client_secret.present?
          redirect_to strava_url
        else
          redirect_to '/users/edit', alert: 'Uzupełnij Strava Client ID i Client Secret!'
        end
      end

      def create
        @response = client.oauth_token(code: params[:code])

        current_user.update(
          strava_access_token: @response.access_token,
          strava_refresh_token: @response.refresh_token,
          strava_expires_at: @response.expires_at
        )
      end

      def callback
        response = client.oauth_token(code: params[:code])

        current_user.update(
          strava_access_token: response.access_token,
          strava_refresh_token: response.refresh_token,
          strava_expires_at: response.expires_at,
          strava_athlete_id: response.athlete.id
        )

        redirect_to '/przejscia', notice: 'Połączono ze Stravą'
      end

      private

      def client
        ::Strava::OAuth::Client.new(
          client_id: current_user.strava_client_id,
          client_secret: current_user.strava_client_secret
        )
      end

      def strava_url
        client.authorize_url(
          redirect_uri: "https://panel.kw.krakow.pl/activities/strava/callback",
          approval_prompt: 'force',
          response_type: 'code',
          scope: 'activity:read_all',
          state: 'magic'
        )
      end
    end
  end
end

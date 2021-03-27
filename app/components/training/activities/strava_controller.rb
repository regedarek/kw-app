module Training
  module Activities
    class StravaController < ApplicationController
      append_view_path 'app/components'

      def new
        redirect_to strava_url
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
          strava_expires_at: response.expires_at
        )

        redirect_to '/przejscia', notice: 'Połączono ze Stravą'
      end

      private

      def client
        ::Strava::OAuth::Client.new(
          client_id: Rails.application.secrets.strava_client,
          client_secret: Rails.application.secrets.strava_secret
        )
      end

      def strava_url
        client.authorize_url(
          redirect_uri: "http://4e4fe666299d.ngrok.io/activities/strava/callback",
          approval_prompt: 'force',
          response_type: 'code',
          scope: 'activity:read_all',
          state: 'magic'
        )
      end
    end
  end
end

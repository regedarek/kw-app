module Training
  module Activities
    class StravaController < ApplicationController
      append_view_path 'app/components'

      def new
        redirect_to strava_url
      end

      def create
        @response = client.oauth_token(code: params[:code])
      end

      def callback

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
          redirect_uri: "#{Rails.application.secrets.localtunnel}/activities/strava",
          approval_prompt: 'force',
          response_type: 'code',
          scope: 'activity:read_all',
          state: 'magic'
        )
      end
    end
  end
end

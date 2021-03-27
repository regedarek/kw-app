module Training
  module Activities
    module Api
      class StravaActivitiesController < ApplicationController
        def index
          activities = strava_fetcher.activities(
            user: Db::User.find(params[:user_id]),
            per_page: params[:pre_page],
            page: params[:page]
          )

          render json: activities.as_json
        end

        def create

        end

        private

        def strava_fetcher
          ::Training::Activities::StravaFetcher.new
        end
      end
    end
  end
end

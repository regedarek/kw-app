module Training
  module Activities
    class SkiRoutesController < ApplicationController
      include EitherMatcher
      append_view_path 'app/components'

      def rules

      end

      def index
        return redirect_to activities_mountain_routes_path, alert: 'musisz byc zalogowany' unless user_signed_in?

        @prev_month_leaders = Training::Activities::Repository.new.fetch_prev_month
        @current_month_leaders = Training::Activities::Repository.new.fetch_current_month
        @season_leaders = Training::Activities::Repository.new.fetch_season
      end

      def new
        return redirect_to activities_mountain_routes_path, alert: 'musisz byc zalogowany' unless user_signed_in?

        @ski_route = ::Db::Activities::MountainRoute.new
      end

      def create
        either(create_record) do |result|
          result.success do
            redirect_to activities_mountain_routes_path, flash: { notice: 'Dodano przejście' }
          end

          result.failure do |errors|
            @ski_route = ::Db::Activities::MountainRoute.new(ski_route_params)
            flash[:error] = errors.values.join(", ")
            render :new
          end
        end
      end

      private

      def create_record
        Training::Activities::CreateSkiRoute.new(
          Training::Activities::Repository.new,
          Training::Activities::SkiRouteForm.new
        ).call(raw_inputs: ski_route_params, user_id: current_user&.id)
      end

      def ski_route_params
        params
          .require(:ski_route)
          .permit(
            :name, :climbing_date, :hidden, :rating, :partners,
            :length, :description, colleagues_names: [],
            attachments: []
          )
      end
    end
  end
end

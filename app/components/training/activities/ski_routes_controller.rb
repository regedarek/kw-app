module Training
  module Activities
    class SkiRoutesController < ApplicationController
      include EitherMatcher
      append_view_path 'app/components'

      def rules

      end

      def index
        @prev_month_leaders = Training::Activities::Repository.new.fetch_prev_month
        @current_month_leaders = Training::Activities::Repository.new.fetch_current_month
        @season_leaders = Training::Activities::Repository.new.fetch_season
        @autum_leaders = Training::Activities::Repository.new.fetch_autum
        @winter_leaders = Training::Activities::Repository.new.fetch_winter
        @spring_leaders = Training::Activities::Repository.new.fetch_spring
      end

      def new
        authorize! :create, ::Db::Activities::MountainRoute

        @ski_route = ::Db::Activities::MountainRoute.new(colleague_ids: [current_user.id], rating: 2)
      end

      def create
        authorize! :create, ::Db::Activities::MountainRoute

        either(create_record) do |result|
          result.success do
            redirect_to activities_mountain_routes_path, flash: { notice: 'Dodano przejście' }
          end

          result.failure do |errors|
            @ski_route = ::Db::Activities::MountainRoute.new(ski_route_params)
            @route = ::Db::Activities::MountainRoute.new(ski_route_params)
            @errors = errors
            render :new
          end
        end
      end

      def edit
        @ski_route = ::Db::Activities::MountainRoute.find(params[:id])
      end

      def update
        @ski_route = ::Db::Activities::MountainRoute.find(params[:id])
        authorize! :manage, @ski_route

        either(update_record) do |result|
          result.success do
            redirect_to edit_activities_ski_route_path(@ski_route.id), flash: { notice: 'Zaktualizowano przejście' }
          end

          result.failure do |errors|
            @errors = errors
            render :edit
          end
        end
      end

      private

      def update_record
        Training::Activities::UpdateSkiRoute.new(
          Training::Activities::Repository.new,
          Training::Activities::SkiRouteForm.new
        ).call(id: params[:id], raw_inputs: ski_route_params, user_id: current_user&.id)
      end

      def create_record
        Training::Activities::CreateSkiRoute.new(
          Training::Activities::Repository.new,
          Training::Activities::SkiRouteForm
        ).call(raw_inputs: ski_route_params, user_id: current_user&.id)
      end

      def ski_route_params
        params
          .require(:ski_route)
          .permit(
            :name, :climbing_date, :training, :hidden, :rating, :partners,
            :length, :description, :area, :difficulty, colleague_ids: [],
            contract_ids: [], attachments: [], gps_tracks: []
          )
      end
    end
  end
end

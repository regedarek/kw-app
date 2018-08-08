module Training
  module Activities
    class HeartsController < ApplicationController
      append_view_path 'app/components'
      respond_to :js

      def heart
        @user = current_user
        @route = ::Db::Activities::MountainRoute.find(params[:mountain_route_id])
        Training::Activities::Hearts.new(@user).heart!(@route)
      end

      def unheart
        @user = current_user
        @heart = @user.hearts.find_by(mountain_route_id: params[:mountain_route_id])
        @route = ::Db::Activities::MountainRoute.find(params[:mountain_route_id])
        @heart.destroy!
      end
    end
  end
end

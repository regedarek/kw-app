module Activities
  class MountainRoutesController < ApplicationController
    def index
      @routes = Db::Activities::MountainRoute.order('climbing_date DESC NULLS LAST').page(params[:page]).per(10)
    end

    def new
      @route = Db::Activities::MountainRoute.new
    end

    def create
      @route = Db::Activities::MountainRoute.new(route_params)
      @route.user_id = current_user.id

      return redirect_to activities_mountain_routes_path, alert: t('.has_to_be_signed_in') unless user_signed_in?

      if @route.save
        redirect_to activities_mountain_routes_path, notice: t('.created_successfully')
      else
        render :new
      end
    end

    private

    def route_params
      params.require(:route).permit(:route_type, :peak, :mountains, :length, :area, :name, :description, :difficulty, :partners, :time, :climbing_date, :rating)
    end
  end
end

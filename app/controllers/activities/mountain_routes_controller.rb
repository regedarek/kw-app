module Activities
  class MountainRoutesController < ApplicationController
    def index
      @routes = Db::Activities::MountainRoute.order(climbing_date: :desc).page(params[:page])
    end

    def new
      @route = Db::Activities::MountainRoute.new
    end

    def edit
      @route = Db::Activities::MountainRoute.find(params[:id])
    end

    def create
      @route = Db::Activities::MountainRoute.new(route_params)
      @route.user_id = current_user.id

      return redirect_to routes_path, alert: t('.has_to_be_signed_in') unless user_signed_in?

      if @route.save
        redirect_to routes_path, notice: t('.created_successfully')
      else
        render :new
      end
    end

    def update
      @route = Db::Activities::MountainRoute.find(params[:id])

      return redirect_to routes_path, alert: t('.you_are_not_owner') unless @route.user_id == current_user.id

      if @route.update_attributes(route_params)
        redirect_to edit_route_path(@route), notice: t('.updated_successfully')
      else
        render :new
      end
    end

    def show
      @route = Db::Activities::MountainRoute.find(params[:id])
    end

    def destroy
      route = Db::Activities::MountainRoute.find(params[:id])
      route.destroy

      redirect_to routes_path, notice: t('.destroyed')
    end

    private

    def route_params
      params.require(:route).permit(:route_type, :name, :description, :difficulty, :partners, :time, :climbing_date, :rating)
    end
  end
end

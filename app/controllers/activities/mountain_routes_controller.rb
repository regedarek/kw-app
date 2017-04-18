module Activities
  class MountainRoutesController < ApplicationController
    def index
      @routes = Db::Activities::MountainRoute
        .text_search(params[:query])
        .order(sort_column + ' ' + sort_direction + ' NULLS LAST')
        .page(params[:page]).per(10)

      respond_to do |format|
        format.html
        format.xlsx do
          disposition = "attachment; filename='przejscia_#{Time.now.strftime("%Y-%m-%d-%H%M%S")}.xlsx'"
          response.headers['Content-Disposition'] = disposition
        end
      end
    end

    def new
      @route = Db::Activities::MountainRoute.new
    end
    
    def show
      @route = Db::Activities::MountainRoute.find(params[:id])
    end

    def edit
      @route = Db::Activities::MountainRoute.find(params[:id])
      return redirect_to activities_mountain_routes_path, alert: t('.not_owner') unless user_signed_in?
      return redirect_to activities_mountain_routes_path, alert: t('.not_owner') unless current_user.admin? || current_user.id == @route.user_id
    end

    def update
      @route = Db::Activities::MountainRoute.find(params[:id])

      if @route.update(route_params)
        redirect_to activities_mountain_route_path(route), notice: t('.updated_successfully')
      else
        render :edit
      end
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

    def destroy
      route = Db::Activities::MountainRoute.find(params[:id])
      fail 'not admin' unless user_signed_in? && (current_user.admin? || current_user.id == route.user_id)
      route.destroy

      redirect_to activities_mountain_routes_path, notice: t('.removed_successfully')
    end

    private

    def route_params
      params.require(:route).permit(:route_type, :peak, :mountains, :length, :area, :name, :description, :difficulty, :partners, :time, :climbing_date, :rating)
    end

    def sort_column
      Db::Activities::MountainRoute.column_names.include?(params[:sort]) ? params[:sort] : 'climbing_date'
    end

    def sort_direction
      %w(asc desc).include?(params[:direction]) ? params[:direction] : 'desc'
    end
  end
end

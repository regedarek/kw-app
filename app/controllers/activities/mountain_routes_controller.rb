module Activities
  class MountainRoutesController < ApplicationController
    append_view_path 'app/components'
    before_action :authenticate_user!, only: [:create, :update, :destroy]

    def index
      authorize! :read, ::Db::Activities::MountainRoute

      if user_signed_in?
        if current_user.ski_hater?
          if params && params.key?(:route_type)
          else
            return redirect_to('/przejscia?route_type=climbing')
          end
        end
      end

      @q = if params[:boars]
             Db::Activities::MountainRoute.includes(:colleagues).where(hidden: false)
           else
             Db::Activities::MountainRoute.includes(:colleagues).where(hidden: false, training: false)
           end
      @q = @q.climbing if params[:route_type] == 'climbing'
      @q = @q.ski if params[:route_type] == 'ski' && params[:boars] != 'true'
      @q = @q.boars if params[:boars] == 'true'
      @q = @q.ransack(params[:q])
      routes = @q.result(distinct: true)
      ordered_routes = routes.sort_by {|route| route.climbing_date.to_date}.reverse!
      @routes = Kaminari.paginate_array(ordered_routes).page(params[:page]).per(10)
      if params[:boars]
        @prev_month_leaders = Training::Activities::Repository.new.fetch_prev_month
        @current_month_leaders = Training::Activities::Repository.new.fetch_current_month
        @season_leaders = Training::Activities::Repository.new.fetch_season
      end

      respond_to do |format|
        format.html
        format.xlsx do
          disposition = "attachment; filename='przejscia_#{Time.now.strftime("%Y-%m-%d-%H%M%S")}.xlsx'"
          response.headers['Content-Disposition'] = disposition
        end
      end
    end

    def photos
      month = Date.new(params[:year].to_i, params[:month].to_i, 1)
      range = month.beginning_of_month..month.end_of_month

      routes = ::Db::Activities::MountainRoute
        .where(
          route_type: 'ski',
          climbing_date: range,
          created_at: range
      ).uniq
      @photos = routes.map(&:attachments).flatten.select { |a| a.content_type.start_with?('image') }
    end

    def new
      authorize! :create, ::Db::Activities::MountainRoute

      @route = Db::Activities::MountainRoute.new
    end

    def show
      @route = Db::Activities::MountainRoute.find(params[:id])
      authorize! :read, @route
    end

    def edit
      @route = Db::Activities::MountainRoute.find(params[:id])
      return redirect_to activities_mountain_routes_path, alert: t('.not_owner') unless user_signed_in?
      return redirect_to activities_mountain_routes_path, alert: t('.not_owner') unless current_user.admin? || current_user.id == @route.user_id || @route.colleagues.include?(current_user)
    end

    def update
      @route = Db::Activities::MountainRoute.find(params[:id])

      if @route.update(route_params)
        redirect_to activities_mountain_route_path(@route), notice: t('.updated_successfully')
      else
        render :edit
      end
    end

    def hide
      route = Db::Activities::MountainRoute.find(params[:id])

      authorize! :hide, route
      route.update(hidden: true)

      redirect_back(fallback_location: activities_mountain_routes_path, notice: t('.hidden_successfully'))
    end

    def create
      @route = Db::Activities::MountainRoute.new(route_params)
      @route.route_type = :regular_climbing
      @route.user_id = current_user.id

      return redirect_to activities_mountain_routes_path, alert: t('.has_to_be_signed_in') unless user_signed_in?

      if @route.save
        redirect_to new_activities_mountain_route_path, notice: "Dziękujemy za dodanie przejścia, możesz teraz dodać kolejne ;)"
      else
        render :new
      end
    end

    def destroy
      route = Db::Activities::MountainRoute.find(params[:id])
      if user_signed_in? && (current_user.admin? || current_user.id == route.user_id)
        route.destroy

        redirect_to activities_mountain_routes_path, notice: t('.removed_successfully')
      else
        redirect_back(fallback_location: root_path, alert: 'Musisz być właścicielem przejścia lub administratorem')
      end
    end

    private

    def route_params
      params.require(:route).permit(:peak, :mountains, :length, :area, :name, :description, :difficulty, :partners, :time, :climbing_date, :route_type, :rating, :hidden, colleagues_names: [], attachments: [])
    end
  end
end

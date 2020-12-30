module Activities
  class MountainRoutesController < ApplicationController
    append_view_path 'app/components'
    before_action :authenticate_user!, only: [:create, :update, :destroy]

   def index
      authorize! :read, ::Db::Activities::MountainRoute

      @q = Db::Activities::MountainRoute
        .includes([:colleagues])
        .accessible_by(current_ability)
        .where(hidden: false)
        .order(climbing_date: :desc)
      @q = @q.where(route_type: params[:route_type]) if params[:route_type]
      unless params[:boars]
        @q = @q.where(training: false)
      else
        @q = @q.where(training: [false, true])
      end
      @q = @q.ransack(params[:q])

      @routes = @q.result(distinct: true).page(params[:page]).per(20)
      if params[:boars]
        @prev_month_leaders = Training::Activities::Repository.new.fetch_prev_month
        @current_month_leaders = Training::Activities::Repository.new.fetch_current_month
        @season_leaders = Training::Activities::Repository.new.fetch_season
      end

      respond_to do |format|
        format.html
        if user_signed_in?
          format.xlsx do
            @current_user = current_user
            disposition = "attachment; filename=przejscia_#{Time.now.strftime("%Y-%m-%d-%H%M%S")}.xlsx"
            response.headers['Content-Disposition'] = disposition
          end
        end
      end
    end

    def photos
      month = Date.new(params[:year].to_i, params[:month].to_i, 1)
      range = month.beginning_of_month..month.end_of_month

      routes = ::Db::Activities::MountainRoute
        .where(
          climbing_date: range,
          created_at: range
      ).uniq
      @photos = routes.map(&:attachments).flatten.select { |a| a.content_type.start_with?('image') }
    end

    def new
      authorize! :create, ::Db::Activities::MountainRoute

      @route = Db::Activities::MountainRoute.new(colleague_ids: [current_user.id], rating: 2)
    end

    def show
      @route = Db::Activities::MountainRoute.includes(:colleagues).friendly.find(params[:id])
      authorize! :read, @route
    end

    def edit
      @route = Db::Activities::MountainRoute.friendly.find(params[:id])
      return redirect_to activities_mountain_routes_path, alert: t('.not_owner') unless user_signed_in?
      return redirect_to activities_mountain_routes_path, alert: t('.not_owner') unless current_user.admin? || current_user.id == @route.user_id || @route.colleagues.include?(current_user)
    end

    def update
      @route = Db::Activities::MountainRoute.friendly.find(params[:id])

      if @route.update(route_params)
        redirect_to edit_activities_mountain_route_path(@route), notice: t('.updated_successfully')
      else
        render :edit
      end
    end

    def hide
      route = Db::Activities::MountainRoute.friendly.find(params[:id])

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
      route = Db::Activities::MountainRoute.friendly.find(params[:id])
      if user_signed_in? && (current_user.admin? || current_user.id == route.user_id)
        route.destroy

        redirect_to activities_mountain_routes_path, notice: t('.removed_successfully')
      else
        redirect_back(fallback_location: root_path, alert: 'Musisz być właścicielem przejścia lub administratorem')
      end
    end

    private

    def route_params
      params.require(:route).permit(:peak, :mountains, :length, :area, :name, :description, :difficulty, :partners, :time, :climbing_date, :route_type, :rating, :hidden, colleague_ids: [], attachments: [])
    end
  end
end

class RoutesController < ApplicationController
  def index
    @routes = Db::Route.order(climbing_date: :desc).page(params[:page])
  end

  def new
    @route = Db::Route.new
    @valleys = Db::Valley.order(:name)
  end

  def edit
    @route = Db::Route.find(params[:id])
    @valleys = Db::Valley.order(:name)
  end

  def create
    @route = Db::Route.new(route_params)
    @valleys = Db::Valley.order(:name)

    return redirect_to routes_path, alert: 'Musisz być zalogowany.' unless user_signed_in?

    if @route.save
      redirect_to routes_path, notice: 'Dodano twoje przejście.'
    else
      render :new
    end
  end

  def update
    @route = Db::Route.find(params[:id])
    @valleys = Db::Valley.order(:name)

    if @route.update_attributes(route_params)
      redirect_to edit_route_path(@route), notice: 'Zaktualizowano przejście.'
    else
      render :new
    end
  end

  def show
    @route = Db::Route.find(params[:id])
  end

  def destroy
    route = Db::Route.find(params[:id])
    route.destroy

    redirect_to routes_path, notice: 'Usunięto przejście.'
  end

  private

  def route_params
    params.require(:route).permit(:route_type, :name, :description, :difficulty, :partners, :peak_id, :time, :climbing_date, :rating)
  end
end

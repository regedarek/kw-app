class EventsController < ApplicationController
  def index
    @events = Db::Event.all
  end

  def show
    @event = Db::Event.find(params[:id])
  end
end

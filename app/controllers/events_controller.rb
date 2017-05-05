class EventsController < ApplicationController
  def index
    @events = Db::Event.order(:event_date)
  end

  def show
    @event = Db::Event.find(params[:id])
  end
end

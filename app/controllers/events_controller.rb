class EventsController < ApplicationController
  def index
    @events = Db::Event.order(:event_date).where('event_date >= ?', Date.today)
  end

  def show
    @event = Db::Event.find(params[:id])
  end
end

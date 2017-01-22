class EventsController < ApplicationController
  def index
    @events = Db::Event.all
  end
end

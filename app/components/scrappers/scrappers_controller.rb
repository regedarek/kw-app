module Scrappers
  class ScrappersController < ApplicationController
    append_view_path 'app/components'

    def index
      @current_date = params[:date] ? params[:date] : Date.today.to_s
      @shmu_record = Scrappers::ShmuRecord.where(diagram_time: Date.today.all_day)
      @topr_record = Scrappers::ToprRecord.find_by(time: @current_date)
      @meteoblue_record = Scrappers::MeteoblueRecord.find_by(time: @current_date)
      @pogodynka_record = Scrappers::WeatherRecord.last
      @routes_records = Db::Activities::MountainRoute.where(climbing_date: @current_date)
    end
  end
end

module Scrappers
  class ScrappersController < ApplicationController
    append_view_path 'app/components'

    def index
      @current_date = params[:date] ? params[:date].to_date : Date.today

      @shmu_records = Scrappers::ShmuRecord.where(diagram_time: @current_date.all_day)
      @topr_record = Scrappers::ToprRecord.find_by(time: @current_date)
      @meteoblue_record = Scrappers::MeteoblueRecord.find_by(time: @current_date.to_s)
      @pogodynka_records = Scrappers::WeatherRecord.where(created_at: @current_date.all_day)
      @routes_records = Db::Activities::MountainRoute.where(climbing_date: @current_date)
    end
  end
end

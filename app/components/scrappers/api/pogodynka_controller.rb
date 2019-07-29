module Scrappers
  module Api
    class PogodynkaController < ::Api::BaseController
      def index
        kasprowy = Scrappers::WeatherRecord
          .where(place: 'Kasprowy Wierch')
          .select(:place, :created_at, :temp)
          .collect {|w| [w.created_at.to_date, w.temp]}

        render json: kasprowy
      end
    end
  end
end

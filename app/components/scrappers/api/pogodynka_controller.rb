module Scrappers
  module Api
    class PogodynkaController < ::Api::BaseController
      def index
        records = {}
        locations.each do |location|
          records[location] = Scrappers::WeatherRecord.where(place: location)
        end

        render json: records
      end

      private

      def locations
        ['Kasprowy Wierch', 'Hala Gąsienicowa', 'Dolina Pięciu Stawów', 'Polana Chochołowska']
      end
    end
  end
end

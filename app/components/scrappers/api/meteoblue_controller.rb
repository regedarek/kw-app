module Scrappers
  module Api
    class MeteoblueController < ::Api::BaseController
      def index
        kasprowy = Scrappers::MeteoblueRecord.where(location: 'Kasprowy Wierch').select(:location, :created_at, :temperature_max).collect {|w| [w.created_at.to_i, w.temperature_max]}

        render json: kasprowy
      end
    end
  end
end

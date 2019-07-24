module Scrappers
  class WeatherStorage
    def call
      pogodynka.call.map do |weather|
        Scrappers::WeatherRecord.new(weather.to_attributes).save!
      end
    end

    private

    def pogodynka
      Scrappers::Pogodynka.new
    end
  end
end

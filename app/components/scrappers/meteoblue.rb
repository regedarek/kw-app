require "open-uri"

module Scrappers
  class Meteoblue
    def call
      response = Net::HTTP.get(kasprowy_uri)
      output = JSON.parse(response)
      parsed_output = output.dig('data_day').map { |k,v| [k, v.first] }.to_h
      parsed_output.tap { |hs| hs.delete('uvindex') }

      meteoblue = Scrappers::MeteoblueRecord.create(parsed_output.merge(location: 'Kasprowy Wierch'))
      meteoblue.update(meteogram: open(meteogram_uri))
    end

    private

    def kasprowy_uri
      URI("http://my.meteoblue.com/packages/basic-day?name=Kasprowy Wierch&forecast_days=1&history_days=1&lat=49.231899&lon=19.981701&asl=1961&tz=Europe%2FWarsaw&apikey=#{Rails.application.secrets.meteoblue_key}&temperature=C&windspeed=ms-1&winddirection=degree&precipitationamount=mm&timeformat=iso8601&format=json")
    end

    def meteogram_uri
      URI.parse("http://my.meteoblue.com/visimage/meteogram_web?name=Kasprowy Wierch&apikey=#{Rails.application.secrets.meteoblue_key}&lat=49.231899&lon=19.9817&asl=1961&tz=Europe%2FWarsaw")
    end
  end
end

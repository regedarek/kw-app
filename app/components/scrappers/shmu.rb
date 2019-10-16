module Scrappers
  class Shmu
    def call
      Scrappers::ShmuRecord.create(
        diagram_time: Time.zone.now,
        remote_image_url: lomnicki_stit_uri(hour: 12).to_s,
        place: 'lomnicki_stit'
      )

      Net::HTTP.get(URI('https://hc-ping.com/8a5d9b79-ed79-4270-a6d7-a40d8b90ce64'))
    end

    private

    def diagram_hour
      12
    end

    def lomnicki_stit_uri(day: Time.zone.now.to_date.to_s(:number), hour: 12)
      URI.parse("http://www.shmu.sk/data/datanwp/v2/meteogram/al-meteogram_31499-#{day}-#{hour}00-nwp-.png")
    end
  end
end

module Scrappers
  class Shmu
    def call
      Scrappers::ShmuRecord.create(
        diagram_time: Time.zone.now,
        remote_image_url: lomnicki_stit_uri(hour: 12).to_s,
        place: 'lomnicki_stit'
      )
    end

    private

    def diagram_hour
      12
    end

    def lomnicki_stit_uri(day: Date.today.to_s(:number), hour: 12)
      URI.parse("http://www.shmu.sk/data/datanwp/v2/meteogram/al-meteogram_31499-#{day}-#{hour}00-nwp-.png")
    end
  end
end

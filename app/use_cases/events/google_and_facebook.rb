module Events
  class GoogleAndFacebook
    def self.fetch_latest
      cal = Google::Calendar.new(
        client_id: Rails.application.secrets.google_client_id,
        client_secret: Rails.application.secrets.google_client_secret,
        calendar: '57vh4rbe6plsa0hdtb6mvhl4cc@group.calendar.google.com',
        redirect_url: "urn:ietf:wg:oauth:2.0:oob",
        refresh_token: "1/RtmXGtd-SygIV40mM2z-CQVmCvgzTX7sdaroWcIZkTk"
      )
      google_events = cal.find_future_events
      google_events[0..5].each do |event|
        Db::Event.create(name: event.title, description: event.description, event_date: event.start_time, place: event.location)
      end
      graph = Koala::Facebook::API.new('EAACEdEose0cBALxj1At0DcteZAJbmHfmY3NnTMrPHxLAtUDsDTbnN28ILRKGVfDOX5t479H9tjXDt9QoThISYzu7nmUPsNZCfIYZCN7JqMpQOz4RUQB3YEcmyEEqarY5hPfCiC5FCdmmTPhy6tdrdRJcalVs3EmjdZAzMHz9mEDFHc4Y2Duv')
      facebook_events = graph.get_object('KlubWysokogorskiKrakow/events')
      facebook_events[0..5].each do |event|
        Db::Event.create(name: event.fetch('name'), event_date: event.fetch('start_time'), place: event.fetch('location'), application_list_url: "https://facebook.com/events/#{event.fetch('id')}")
      end
    end
  end
end

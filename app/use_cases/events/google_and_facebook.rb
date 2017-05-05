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
      events = cal.find_future_events
      events[0..5].each do |event|
        Db::Event.create(name: event.title, description: event.description, event_date: event.start_time, place: event.location)
      end
    end
  end
end

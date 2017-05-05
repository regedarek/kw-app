module Events
  class CreateEvent
    def initialize(params:, kw_id:)
      @allowed_params = params
      @kw_id = kw_id
    end

    def create
      cal = Google::Calendar.new(
        client_id: Rails.application.secrets.google_client_id,
        client_secret: Rails.application.secrets.google_client_secret,
        calendar: '57vh4rbe6plsa0hdtb6mvhl4cc@group.calendar.google.com',
        redirect_url: "urn:ietf:wg:oauth:2.0:oob",
        refresh_token: "1/RtmXGtd-SygIV40mM2z-CQVmCvgzTX7sdaroWcIZkTk"
      )
      if form.valid?
        event = Db::Event.new(form.params)
        event.manager_kw_id = @kw_id
        event.save
        cal.create_event do |e|
          e.title = event.name
          e.location = event.place
          e.start_time = event.event_date
          e.end_time = event.event_date + 1.hour
        end
        Success.new
      else
        Failure.new(:invalid, form: form)
      end
    end

    def form
      @form ||= Events::Form.new(@allowed_params)
    end
  end
end

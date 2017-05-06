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
        refresh_token: Db::User.find_by(kw_id: @kw_id).try(:refresh_token)
      )
      if form.valid?
        event = Db::Event.new(form.params)
        event.manager_kw_id = @kw_id
        if event.save
          cal.create_event do |e|
            e.title = event.name
            e.location = event.place
            e.description = Rails.application.routes.url_helpers.event_url(Db::Event.first, host: ActionMailer::Base.default_url_options[:host])
            e.start_time = event.event_date
            e.end_time = event.event_date + 1.hour
          end
          Success.new(event: event)
        else
          Failure.new(:invalid, form: form)
        end
      else
        Failure.new(:invalid, form: form)
      end
    end

    def form
      @form ||= Events::Form.new(@allowed_params)
    end
  end
end

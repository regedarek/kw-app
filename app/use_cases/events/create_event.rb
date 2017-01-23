module Events
  class CreateEvent
    def initialize(params:, kw_id:)
      @allowed_params = params
      @kw_id = kw_id
    end

    def create
      if form.valid?
        event = Db::Event.new(form.params)
        event.manager_kw_id = @kw_id
        event.save
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

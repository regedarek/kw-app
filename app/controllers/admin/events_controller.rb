module Admin
  class EventsController < Admin::BaseController
    def new
      @form = Events::Form.new
    end

    def create
      result = Events::CreateEvent.new(params: event_params, kw_id: current_user.kw_id).create
      result.success { |event:| redirect_to admin_event_path(event.id), notice: 'Dodano wydarzenie' }
      result.invalid do |form:|
        @form = form
        render :new
      end
      result.else_fail!
    end
    
    def show
      @event = Db::Event.find(params[:id])
    end

    def destroy
      event = Db::Event.find(params[:id])
      event.destroy

      redirect_to events_path, notice: 'Usunięto wydarzenie'
    end


    private

    def event_params
      params.require(:event).permit(
        :name, :place, :event_date, :manager_kw_id, :participants, :application_list_url,
        :price_for_members, :price_for_non_members, :application_date, :payment_date,
        :account_number, :event_rules_url, :google_group_discussion_url, :description
      )
    end
  end
end

module Events
  module Admin
    class CompetitionsController < ::Admin::BaseController
      include EitherMatcher
      respond_to :html, :xlsx
      append_view_path 'app/components'

      def index
        if params[:archive]
          @competitions = Events::Db::CompetitionRecord.all.order("event_date DESC nulls last")
        else
          @competitions = Events::Db::CompetitionRecord.where('event_date >= ?', Time.now).or(
            Events::Db::CompetitionRecord.where(event_date: nil)
          ).order("event_date DESC nulls last")
        end
      end

      def new
        @competition = Events::Db::CompetitionRecord.new
      end

      def edit
        @competition = Events::Db::CompetitionRecord.find(params[:id])
      end

      def update
        @competition = Events::Db::CompetitionRecord.find(params[:id])

        either(update_record(id: @competition.id)) do |result|
          result.success do
            redirect_to edit_admin_competition_path(@competition.id), flash: { notice: 'Zaktualizowano zawody' }
          end

          result.failure do |errors|
            flash[:error] = errors.values.join(", ")
            redirect_to admin_competitions_path, flash: { alert: 'Błąd' }
          end
        end
      end

      def show
        @competition = Events::Db::CompetitionRecord.find(params[:id])

        respond_with do |format|
          format.html
          format.xlsx do
            disposition = "attachment; filename=#{@competition.edition_sym}_#{Time.now.strftime("%Y-%m-%d-%H%M%S")}.xlsx"
            response.headers['Content-Disposition'] = disposition
          end
        end
      end

      def create
        @competition = Events::Db::CompetitionRecord.new(competition_params)

        either(create_record) do |result|
          result.success do
            redirect_to admin_competitions_path, flash: { notice: 'Utworzono zawody' }
          end

          result.failure do |errors|
            flash[:error] = errors.values.join(", ")
            render :new
          end
        end
      end

      def toggle_closed
        competition = Events::Db::CompetitionRecord.find(params[:id])
        competition.toggle!(:closed)
        redirect_to admin_competitions_path, flash: { success: "Zapisy #{competition.closed? ? 'zamknięte' : 'otwarte'}" }
      end

      private

      def authorize_admin
        redirect_to root_url, alert: 'Nie jestes administratorem!' unless user_signed_in? && (current_user.roles.include?('competitions') || current_user.admin?)
      end

      def create_record
        Events::Admin::Competitions::Create.new(
          Events::Competitions::Repository.new,
          Events::Admin::Competitions::CreateForm.new
        ).call(raw_inputs: competition_params)
      end

      def update_record(id:)
        Events::Admin::Competitions::Update.new(
          Events::Competitions::Repository.new,
          Events::Admin::Competitions::CreateForm.new
        ).call(id: id, raw_inputs: competition_params)
      end

      def competition_params
        params
          .require(:competition)
          .permit(
            :name, :edition_sym, :rules, :baner, :single, :team_name, :event_date, :accept_first, :rules_text, :sign_up_starts_at, :weekend_nights,
            :closed, :limit, :custom_form, :email_text, :en_email_text, :matrimonial_office, :tshirt_url, :alert, :close_payment, :medical_rules_text, :weekend_nights_text,
            :organizer_email, :info_above_sign_ups, package_types_attributes: [:id, :membership, :name, :cost, :_destroy]
          )
      end
    end
  end
end

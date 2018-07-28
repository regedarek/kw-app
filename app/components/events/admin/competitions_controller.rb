module Events
  module Admin
    class CompetitionsController < ::Admin::BaseController
      include EitherMatcher
      respond_to :html, :xlsx
      append_view_path 'app/components'

      def index
        @competitions = Events::Db::CompetitionRecord.all
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
            disposition = "attachment; filename='#{@competition.edition_sym}_#{Time.now.strftime("%Y-%m-%d-%H%M%S")}.xlsx'"
            response.headers['Content-Disposition'] = disposition
          end
        end
      end

      def create
        either(create_record) do |result|
          result.success do
            redirect_to admin_competitions_path, flash: { notice: 'Utworzono zawody' }
          end

          result.failure do |errors|
            flash[:error] = errors.values.join(", ")
            redirect_to admin_competitions_path, flash: { alert: 'Błąd' }
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
            :name, :edition_sym, :rules, :baner, :single, :team_name,
            :closed, :limit, :email_text, :matrimonial_office, :tshirt_url,
            :organizer_email
          )
      end
    end
  end
end

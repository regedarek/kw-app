module Events
  module Admin
    class CompetitionsController < ::Admin::BaseController
      include EitherMatcher
      respond_to :html, :xlsx
      append_view_path 'app/components'

      def index
        @competitions = Events::Db::CompetitionRecord.all
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

      private

      def create_record
        Events::Admin::Competitions::Create.new(
          Events::Competitions::Repository.new,
          Events::Admin::Competitions::CreateForm.new
        ).call(raw_inputs: competition_params)
      end

      def competition_params
        params
          .require(:competition)
          .permit(:name, :edition_sym, :rules, :baner_url, :single, :team_name)
      end
    end
  end
end

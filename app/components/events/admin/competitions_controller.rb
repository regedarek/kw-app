module Events
  module Admin
    class CompetitionsController < ::Admin::BaseController
      include EitherMatcher
      append_view_path 'app/components'

      def index
        @competitions = Events::Db::CompetitionRecord.all
      end

      def create
        either(create_record) do |result|
          result.success do
            redirect_to admin_competitions_path, flash: { notice: 'Utworzono zawody' }
          end

          result.failure do |errors|
            flash[:error] = errors.values.join(", ")
            render(action: :new)
          end
        end
      end

      private

      def create_record
        Events::Admin::Competitions::Create.new(
          Events::Repositories::Competitions.new,
          Events::Admin::Competitions::CreateForm.new
        ).call(raw_inputs: competition_params)
      end

      def competition_params
        params
          .require(:competition)
          .permit(:name)
      end
    end
  end
end

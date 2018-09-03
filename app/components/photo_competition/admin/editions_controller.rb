module PhotoCompetition
  module Admin
    class EditionsController < ::Admin::BaseController
      append_view_path 'app/components'

      def index
        @editions = PhotoCompetition::EditionRecord.all
      end

      def show
        @edition = PhotoCompetition::EditionRecord.find(params[:id])
      end
    end
  end
end

module PhotoCompetition
  module Admin
    class EditionsController < ::Admin::BaseController
      append_view_path 'app/components'

      def index
        @editions = PhotoCompetition::EditionRecord.all
      end

      def show
        @edition = PhotoCompetition::EditionRecord.find(params[:id])
        @q = @edition.photo_requests.ransack(params[:q])
        @photo_requests = @q.result(distinct: true).page(params[:page])
      end
    end
  end
end

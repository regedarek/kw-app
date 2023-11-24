module PhotoCompetition
  module Admin
    class EditionsController < ::Admin::BaseController
      append_view_path 'app/components'

      def index
        @editions = PhotoCompetition::EditionRecord.all
      end

      def show
        @edition = PhotoCompetition::EditionRecord.includes(photo_requests: [:category, :edition, :user]).find(params[:id])
        @q = @edition.photo_requests.order(:created_at).ransack(params[:q])
        @photo_requests = @q.result(distinct: true).page(params[:page])
      end
    end
  end
end

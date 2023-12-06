module PhotoCompetition
  module Admin
    class EditionsController < ::Admin::BaseController
      append_view_path 'app/components'

      def index
        @editions = PhotoCompetition::EditionRecord.order(updated_at: :desc)
      end

      def show
        @edition = PhotoCompetition::EditionRecord.find(params[:id])
        @photo_requests = PhotoCompetition::RequestRecord
          .includes(:category, :edition, :user)
          .where(edition_record_id: @edition.id)
          .order(accepted: :asc)

        @photo_requests = @photo_requests.where(category_record_id: params[:category_record_id]) if params[:category_record_id].present?

        @q = @photo_requests.order(updated_at: :desc).ransack(params[:q])
        @photo_requests = @q.result(distinct: true).page(params[:page]).per(10)
      end
    end
  end
end

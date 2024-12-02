module PhotoCompetition
  module Admin
    class EditionsController < ::Admin::BaseController
      append_view_path 'app/components'

      def index
        @editions = PhotoCompetition::EditionRecord.order(created_at: :desc)
      end

      def show
        @edition = PhotoCompetition::EditionRecord.find(params[:id])
        if params[:accepted] == 'false'
          @photo_requests = PhotoCompetition::RequestRecord
            .includes(:category, :edition, :user)
            .where(edition_record_id: params[:id], accepted: false)
            .order(accepted: :asc)
        else
          @photo_requests = PhotoCompetition::RequestRecord
            .includes(:category, :edition, :user)
            .where(edition_record_id: params[:id], accepted: true)
            .order(accepted: :asc)
        end

        @photo_requests = @photo_requests.where(category_record_id: params[:category_record_id]) if params[:category_record_id].present?

        @q = @photo_requests.order(likes_count: :desc, updated_at: :desc).ransack(params[:q])
        @photo_requests = @q.result(distinct: true).page(params[:page]).per(10)
      end

      def edit
        @edition = PhotoCompetition::EditionRecord.find(params[:id])
      end

      def update
        @edition = PhotoCompetition::EditionRecord.find(params[:id])
        if @edition.update(edition_params)
          redirect_to admin_editions_path, notice: 'Edition was successfully updated.'
        else
          render :edit
        end
      end

      private

      def edition_params
        params.require(:edition).permit(:name, :code, :closed, :start_voting_date, :end_voting_date)
      end
    end
  end
end

module PhotoCompetition
  class EditionsController < ::Admin::BaseController
    append_view_path 'app/components'

    def show
      @edition = PhotoCompetition::EditionRecord.find_by!(code: params[:edition_code])
      if Date.today >= '15-12-2023'.to_date
        @photo_requests = PhotoCompetition::RequestRecord.where(accepted: true, edition_record_id: @edition.id)
          .includes(:category, :edition).order(likes_count: :desc).page(params[:page]).per(20)
      else
        @photo_requests = PhotoCompetition::RequestRecord.where(accepted: true, edition_record_id: @edition.id)
          .includes(:category, :edition).order(updated_at: :desc).page(params[:page]).per(20)
      end
    end
  end
end
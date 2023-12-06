module PhotoCompetition
  class EditionsController < ::Admin::BaseController
    append_view_path 'app/components'

    def show
      return redirect_to root_url, alert: 'Musisz być zalogowany!' unless user_signed_in?

      @edition = PhotoCompetition::EditionRecord.find_by!(code: params[:edition_code])
      if Date.today >= '15-12-2023'.to_date
        @photo_requests = PhotoCompetition::RequestRecord.where(accepted: true, edition_record_id: @edition.id).includes(:category, :edition)
        @photo_requests = @photo_requests.where(category_record_id: params[:category_record_id]) if params[:category_record_id].present?
        @photo_requests = @photo_requests.order(likes_count: :desc).page(params[:page]).per(20)
      else
        @photo_requests = PhotoCompetition::RequestRecord.where(accepted: true, edition_record_id: @edition.id).includes(:category, :edition)
        @photo_requests = @photo_requests.where(category_record_id: params[:category_record_id]) if params[:category_record_id].present?
        @photo_requests = @photo_requests.order(updated_at: :desc).page(params[:page]).per(20)
      end
    end
  end
end

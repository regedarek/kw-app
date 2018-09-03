module PhotoCompetition
  class RequestsController < ApplicationController
    append_view_path 'app/components'

    def new
      @edition = PhotoCompetition::EditionRecord.find_by(code: params[:edition_id])
      @request = @edition.photo_requests.new
    end

    def create
      @edition = PhotoCompetition::EditionRecord.find_by(code: params[:edition_id])

      request = @edition.photo_requests.new(request_params)
      request.user_id = current_user.id

      if request.save
        redirect_to :back, notice: 'Wysłano'
      else
        redirect_to :back, alert: 'Nie wysłano'
      end
    end

    private

    def request_params
      params.require(:request).permit(:description, :file)
    end
  end
end

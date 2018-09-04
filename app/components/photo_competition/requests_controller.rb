module PhotoCompetition
  class RequestsController < ApplicationController
    append_view_path 'app/components'

    def new
      return redirect_to root_url, alert: 'Musisz być zalogowany!' unless user_signed_in?

      @edition = PhotoCompetition::EditionRecord.find_by(code: params[:edition_id])
      @request = @edition.photo_requests.new
    end

    def create
      return redirect_to root_url, alert: 'Musisz być zalogowany!' unless user_signed_in?

      @edition = PhotoCompetition::EditionRecord.find_by(code: params[:edition_id])

      @request = @edition.photo_requests.new(request_params)
      @request.user_id = current_user.id

      if @request.save
        redirect_to new_edition_request_path(edition_id: @edition.code), notice: "Zdjęcie zostało zgłoszone do konkursu w kategorii #{@request.category.name}!"
      else
        render :new
      end
    end

    private

    def request_params
      params.require(:request).permit(:description, :file, :category_record_id)
    end
  end
end

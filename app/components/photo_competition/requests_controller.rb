module PhotoCompetition
  class RequestsController < ApplicationController
    append_view_path 'app/components'

    def new
      return redirect_to root_url, alert: 'Musisz być zalogowany!' unless user_signed_in?

      @edition = PhotoCompetition::EditionRecord.find_by(code: params[:edition_id])
      @request = @edition.photo_requests.new
    end

    def show
      @edition = PhotoCompetition::EditionRecord.find_by(code: params[:edition_id])
      @request = PhotoCompetition::RequestRecord.find(params[:id])
    end

    def create
      return redirect_to root_url, alert: 'Musisz być zalogowany!' unless user_signed_in?

      @edition = PhotoCompetition::EditionRecord.find_by(code: params[:edition_id])

      @request = @edition.photo_requests.new(request_params)
      @request.original_filename = request_params[:file]&.original_filename
      @request.user_id = current_user.id

      if @request.save
        redirect_to new_edition_request_path(edition_id: @edition.code), notice: "Zdjęcie zostało zgłoszone do konkursu w kategorii #{@request.category.name}!"
      else
        render :new
      end
    end

    def accept
      return redirect_to root_url, alert: 'Musisz być zalogowany i mieć dostęp do zdjęć!' unless user_signed_in? && current_user.roles.include?('photo_competition')

      @request = PhotoCompetition::RequestRecord.find(params[:id])

      if @request.accepted?
        @request.update(accepted: false)
      else
        @request.update(accepted: true)
      end

      redirect_to edition_path(id: @request.edition.id), notice: 'Zdjęcie zostało zaakceptowane!'
    end

    private

    def request_params
      params.require(:request).permit(:description, :file, :category_record_id, :file_cache, :title, :area)
    end
  end
end

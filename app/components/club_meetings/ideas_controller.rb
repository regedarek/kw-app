module ClubMeetings
  class IdeasController < ApplicationController
    include EitherMatcher
    append_view_path 'app/components'

    def index
      return redirect_to root_url, alert: 'Nie masz dostępu!' unless user_signed_in? && (current_user.roles.include?('club_meetings') || current_user.admin?)

      @ideas = ClubMeetings::IdeaRecord.includes(:user).all
    end

    def show
      @idea = ClubMeetings::IdeaRecord.friendly.find(params[:id])
    end

    def new
      @idea = ClubMeetings::IdeaRecord.new
    end

    def create
      @idea = ClubMeetings::IdeaRecord.new(idea_params)
      @idea.user_id = current_user.id

      if @idea.save
        redirect_to root_path, notice: 'Pomysł został zgłoszony, czekaj na kontakt od koordynatora.'
      else
        render :new
      end
    end

    private

    def idea_params
      params.require(:idea).permit(:name, :description, photos_attributes: [:file, :filename, :user_id])
    end
  end
end

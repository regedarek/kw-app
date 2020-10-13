module Activities
  class CompetitionsController < ApplicationController
    append_view_path 'app/components'

    def index
      @q = Activities::CompetitionRecord.ransack(params[:q])
      @q.sorts = 'start_date asc' if @q.sorts.empty?
      @competitions = @q.result(distinct: true)

      @competition = Activities::CompetitionRecord.new
    end

    def new
      @competition = Activities::CompetitionRecord.new
    end

    def create
      @competition = Activities::CompetitionRecord.new(competition_params)
      @competition.creator_id = current_user.id
      if @competition.start_date && !@competition.end_date
        @competition.end_date = @competition.start_date
      end

      if @competition.save
        redirect_to new_competition_path, notice: 'Dodano zawody'
      else
        render :new
      end
    end

    def edit
      @competition = Activities::CompetitionRecord.find(params[:id])
    end

    def update
      @competition = Activities::CompetitionRecord.find(params[:id])

      if @competition.update(competition_params)
        redirect_to edit_competition_path(@competition.id), notice: 'Zaktualizowano zawody'
      else
        render :edit
      end
    end

    def destroy
      @competition = Activities::CompetitionRecord.find(params[:id])
      @competition.destroy

      redirect_to competitions_path(q: params.to_unsafe_h[:q]), notice: 'Usunięto kurs'
    end

    private

    def competition_params
      params.require(:competition).permit(:name, :description, :start_date, :end_date, :website, :bold, :series,
                                          :creator_id, :country, :category_type, :slug, :state)
    end
  end
end

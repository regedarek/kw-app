module Management
  class ResolutionsController < ApplicationController
    include EitherMatcher
    append_view_path 'app/components'

    def index
      @q = Management::ResolutionRecord.accessible_by(current_ability)
      @q = @q.ransack(params[:q])
      @q.sorts = ['state desc', 'passed_date desc'] if @q.sorts.empty?
      @resolutions = @q.result(distinct: true).page(params[:page])
    end

    def new
      authorize! :manage, Management::ResolutionRecord

      @resolution = Management::ResolutionRecord.new
    end

    def create
      authorize! :manage, Management::ResolutionRecord
      @resolution = Management::ResolutionRecord.new(resolution_params)

      if @resolution.save
        redirect_to resolutions_path, notice: 'Dodano'
      else
        render :new
      end
    end

    def show
      authorize! :read, Management::ResolutionRecord

      @resolution = Management::ResolutionRecord.friendly.find(params[:id])
    end

    def edit
      authorize! :manage, Management::ResolutionRecord

      @resolution = Management::ResolutionRecord.friendly.find(params[:id])
    end

    def update
      authorize! :manage, Management::ResolutionRecord

      @resolution = Management::ResolutionRecord.friendly.find(params[:id])

      if @resolution.update(resolution_params)
        redirect_to resolution_path(@resolution), notice: 'Zaktualizowano'
      else
        render :edit
      end
    end

    def destroy
      authorize! :manage, Management::ResolutionRecord

      @resolution = Management::ResolutionRecord.friendly.find(params[:id])

      @resolution.destroy
      redirect_to resolutions_path, notice: 'Usunięto'
    end

    private

    def resolution_params
      params.require(:resolution).permit(:name, :state, :passed_date, :number, :description, attachments_attributes: [:file, :filename])
    end
  end
end

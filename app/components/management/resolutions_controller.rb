module Management
  class ResolutionsController < ApplicationController
    include EitherMatcher
    append_view_path 'app/components'

    def index
      @resolutions = Management::ResolutionRecord.all
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
      params.require(:resolution).permit(:name, :number, :description, attachments_attributes: [:file, :filename])
    end
  end
end

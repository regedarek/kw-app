module PhotoCompetition
  module Admin
    module Editions
      class CategoriesController < ::Admin::BaseController
        append_view_path 'app/components'

        def new
          @edition = PhotoCompetition::EditionRecord.find(params[:edition_id])
          @category = @edition.categories.new
        end

        def create
          @edition = PhotoCompetition::EditionRecord.find(params[:edition_id])

          @category = @edition.categories.new(edition_params)

          if @category.save
            redirect_to admin_edition_path(@edition), notice: 'Category was successfully created.'
          else
            render :new
          end
        end

        def edit
          @edition = PhotoCompetition::EditionRecord.find(params[:edition_id])
          @category = @edition.categories.find(params[:id])
        end

        def update
          @edition = PhotoCompetition::EditionRecord.find(params[:edition_id])
          @category = @edition.categories.find(params[:id])

          if @category.update(edition_params)
            redirect_to admin_edition_path(@edition), notice: 'Category was successfully updated.'
          else
            render :edit
          end
        end

        private

        def edition_params
          params.require(:category).permit(:name, :mandatory_fields)
        end
      end
    end
  end
end

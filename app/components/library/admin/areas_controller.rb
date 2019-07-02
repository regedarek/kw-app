module Library
  module Admin
    class AreasController < ApplicationController
      include EitherMatcher
      append_view_path 'app/components'

      def index
        @areas = ::Library::AreaRecord.all
      end

      def new
        @area = Library::AreaRecord.new
      end

      def create
        @area = Library::AreaRecord.new(area_params)

        if @area.save
          redirect_to admin_areas_path, notice: 'Rejon dodany!'
        else
          render :new
        end
      end

      private

      def area_params
        params.require(:area).permit(:name, :description)
      end
    end
  end
end

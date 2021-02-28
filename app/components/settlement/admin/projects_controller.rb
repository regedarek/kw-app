module Settlement
  module Admin
    class ProjectsController < ApplicationController
      include EitherMatcher
      append_view_path 'app/components'

      def index
        @projects = Settlement::ProjectRecord.all
      end

      def new
        @project = Settlement::ProjectRecord.new
      end

      def create
        @project = Settlement::ProjectRecord.new(project_params)

        if @project.save
          redirect_to admin_project_path(@project.id), notice: 'Utworzono projekt'
        else
          render :new
        end
      end

      def show
        @project = Settlement::ProjectRecord.find(params[:id])
      end

      private

      def project_params
        params
          .require(:project)
          .permit(:name, :description, :user_id)
      end
    end
  end
end

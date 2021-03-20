module Settlement
  module Admin
    class ProjectsController < ApplicationController
      include EitherMatcher
      append_view_path 'app/components'

      def index
        @opened_projects = Settlement::ProjectRecord.opened
        @closed_projects = Settlement::ProjectRecord.closed
      end

      def new
        @project = Settlement::ProjectRecord.new
      end

      def create
        @project = Settlement::ProjectRecord.new(project_params)
        @project.user_id = current_user.id

        if @project.save
          redirect_to admin_project_path(@project.id), notice: 'Utworzono projekt'
        else
          render :new
        end
      end

      def destroy
        @project = Settlement::ProjectRecord.find(params[:id])

        @project.destroy
        redirect_to admin_projects_path, notice: 'Usunięto projekt'
      end

      def show
        @project = Settlement::ProjectRecord.find(params[:id])
      end

      def close
        @project = Settlement::ProjectRecord.find(params[:id])
        @project.close!
        redirect_to admin_projects_path, notice: 'Zamknięto projekt'
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

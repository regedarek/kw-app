module Settlement
  module Admin
    class ProjectsController < ApplicationController
      include EitherMatcher
      append_view_path 'app/components'

      def index
        @q = Settlement::ProjectRecord.ransack(params[:q])
        @projects = @q.result(distinct: true).order(created_at: :desc)
        @search_projects  = @projects.page(params[:search_page]).per(15)
        @current_projects = @projects.opened.where.not(area_type: 'course_budget').page(params[:current_page]).per(15)
        @courses_projects = @projects.opened.where(area_type: 'course_budget').page(params[:courses_page]).per(15)
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

      def edit
        @project = Settlement::ProjectRecord.find(params[:id])
      end

      def update
        @project = Settlement::ProjectRecord.find(params[:id])

        if @project.update(project_params)
          redirect_to admin_project_path(@project.id), notice: 'Zmieniono projekt'
        else
          render :edit
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
          .permit(:name, :description, :user_id, :area_type, :state)
      end
    end
  end
end

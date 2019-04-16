module Management
  class ProjectsController < ApplicationController
    include EitherMatcher
    append_view_path 'app/components'

    def index
      @projects = Management::ProjectRecord.order(created_at: :desc)
    end

    def new
      @project = Management::ProjectRecord.new
    end

    def create
      either(create_record) do |result|
        result.success do
          redirect_to projects_path, flash: { notice: 'Utworzono projekt' }
        end

        result.failure do |errors|
          @project = Management::ProjectRecord.new(project_params)
          @errors = errors.map(&:to_sentence)
          render :new
        end
      end
    end

    def show
      @project = Management::ProjectRecord.find(params[:id])
    end

    private

    def create_record
      Management::CreateProject.new(
        Management::ProjectForm
      ).call(raw_inputs: project_params)
    end

    def project_params
      params
        .require(:project)
        .permit(:name, :description, users_names: [], attachments: [])
    end
  end
end

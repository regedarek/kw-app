module Settlement
  module Admin
    class ProjectItemsController < ApplicationController
      append_view_path 'app/components'

      def create
        project_item = Settlement::ProjectItemRecord.new(project_item_params)
        @project = Settlement::ProjectRecord.find(project_item_params[:project_id])

        if project_item.save
          redirect_to admin_project_path(@project.id)
        else
          flash[:alert] = project_item.errors.full_messages
          redirect_to admin_project_path(@project.id)
        end
      end

      def update
        project_item = Settlement::ProjectItemRecord.find(params[:id])

        project_item.update(project_item_params)
        redirect_to admin_project_path(project_item.project.id)
      end

      private

      def project_item_params
        params
          .require(:project_item)
          .permit(:cost, :accountable_type, :accountable_id, :user_id, :project_id)
      end
    end
  end
end

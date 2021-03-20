module Settlement
  module Admin
    class ProjectItemsController < ApplicationController
      def update
        project_item = Settlement::ProjectItemRecord.find(params[:id])

        project_item.update(project_item_params)
        redirect_to admin_project_path(project_item.project.id)
      end

      private

      def project_item_params
        params
          .require(:project_item)
          .permit(:cost)
      end
    end
  end
end

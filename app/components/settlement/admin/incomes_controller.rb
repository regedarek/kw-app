module Settlement
  module Admin
    class IncomesController < ApplicationController
      def create
        income = Settlement::IncomeRecord.new(income_params)

        if income.save(income_params)
          project_item = ProjectItemRecord.create(user_id: current_user.id, project_id: params[:project_id], accountable: income)
          redirect_to admin_project_path(params[:project_id])
        else
          redirect_to admin_project_path(params[:project_id])
        end
      end

      private

      def income_params
        params
          .require(:income)
          .permit(:name, :description, :cost)
      end
    end
  end
end

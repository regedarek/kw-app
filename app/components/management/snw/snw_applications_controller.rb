module Management
  module Snw
    class SnwApplicationsController < ApplicationController
      append_view_path 'app/components'

      def index
        @applications = Management::Snw::ApplicationRecord.all
        @application = Management::Snw::ApplicationRecord.new
      end

      def create
        @application = Management::Snw::ApplicationRecord.new(course_params)

        authorize! :create, @application
        @application.creator_id = current_user.id

        if @application.save
          redirect_to snw_applications_path, notice: 'Utworzono zgłoszenie'
        else
          render :index
        end
      end

      private

      def course_params
        params.require(:application).permit(:name, :user_id)
      end
    end
  end
end

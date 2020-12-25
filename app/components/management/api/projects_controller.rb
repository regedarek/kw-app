module Management
  module Api
    class ProjectsController < ApplicationController
      include Pagy::Backend
      after_action { pagy_headers_merge(@pagy) if @pagy }

      def index
        projects = Management::ProjectRecord.includes(:users).order(created_at: :desc)

        @pagy, records = pagy(projects)

        render json: records, each_serializer: Management::ProjectSerializer
      end
    end
  end
end

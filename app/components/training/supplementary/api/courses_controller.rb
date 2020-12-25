module Training
  module Supplementary
    module Api
      class CoursesController < ApplicationController
        include Pagy::Backend
        after_action { pagy_headers_merge(@pagy) if @pagy }

        def index
          courses = Training::Supplementary::CourseRecord.published
          courses = courses.where(kind: params[:kind]) if params[:kind]
          courses = courses.where(category: params[:category]) if params[:category]
          courses = courses.order(params[:order] => :desc) if params[:order]

          @pagy, records = pagy(courses)

          render json: records, each_serializer: Training::Supplementary::Serializers::CourseSerializer
        end
      end
    end
  end
end

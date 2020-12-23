module Training
  module Supplementary
    module Api
      class CoursesController < ApplicationController
        def index
          courses = Training::Supplementary::CourseRecord.published
          courses = courses.where(kind: params[:kind]) if params[:kind]
          courses = courses.where(category: params[:category]) if params[:category]
          courses = courses.order(params[:order] => :desc) if params[:order]

          render json: courses.limit(5), each_serializer: Training::Supplementary::Serializers::CourseSerializer
        end
      end
    end
  end
end

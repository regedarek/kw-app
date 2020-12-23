module Training
  module Supplementary
    module Api
      class CoursesController < ApplicationController
        def index
          courses = Training::Supplementary::CourseRecord.all

          render json: courses.limit(5), each_serializer: Training::Supplementary::Serializers::CourseSerializer
        end
      end
    end
  end
end

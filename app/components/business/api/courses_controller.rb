module Business
  module Api
    class CoursesController < ApplicationController
      def index
        courses = Business::CourseRecord.all

        render json: courses.to_json
      end
    end
  end
end

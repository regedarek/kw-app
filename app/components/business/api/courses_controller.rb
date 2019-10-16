module Business
  module Api
    class CoursesController < ApplicationController
      def index
        courses = Business::CourseRecord.order(starts_at: :asc)

        render json: courses.to_json
      end
    end
  end
end

module Business
  module Api
    class CoursesController < ApplicationController
      def index
        courses = Business::CourseRecord.order(starts_at: :asc)
        courses = courses.limit(params[:limit]) if params[:limit]

        render json: courses.to_json
      end
    end
  end
end

module Business
  module Api
    class CoursesController < ApplicationController
      def index
        courses = Business::CourseRecord.where.not(max_seats: nil).order(starts_at: :asc)
        filtered_courses = courses.select{ |c| c.max_seats - c.seats > 0 }

        render json: filtered_courses.to_json
      end
    end
  end
end

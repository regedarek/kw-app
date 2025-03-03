module Business
  module Api
    class CoursesController < ApplicationController
      def index
        courses = Business::CourseRecord.where(state: 'ready').where("start_date >= ?", Date.today)
        courses = courses.order(starts_at: :desc)
        courses = courses.limit(params[:limit]) if params[:limit]

        render json: courses.to_json
      end
    end
  end
end

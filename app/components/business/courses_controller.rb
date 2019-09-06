module Business
  class CoursesController < ApplicationController
    append_view_path 'app/components'

    def index
      @courses = Business::CourseRecord.all
      @course = Business::CourseRecord.new
    end

    def create
      @course = Business::CourseRecord.new(course_params)

      authorize! :create, @course
      @course.activity_type = 1
      @course.creator_id = current_user.id

      if @course.save
        redirect_to courses_path, notice: 'Dodano kurs'
      else
        render :index
      end
    end

    private

    def course_params
      params.require(:course).permit(:name, :seats, :starts_at, :ends_at, :description, :activity_type)
    end
  end
end

module Business
  class CoursesController < ApplicationController
    append_view_path 'app/components'

    def index
      @courses = Business::CourseRecord.all
      @course = Business::CourseRecord.new
    end

    def new
      @course = Business::CourseRecord.new
    end

    def create
      @course = Business::CourseRecord.new(course_params)

      @course.activity_type = 1
      @course.creator_id = current_user.id

      if @course.save
        redirect_to courses_path, notice: 'Dodano kurs'
      else
        render :index
      end
    end

    def edit
      @course = Business::CourseRecord.find(params[:id])
    end

    def update
      @course = Business::CourseRecord.find(params[:id])

      if @course.update(course_params)
        redirect_to edit_course_path(@course.id), notice: 'Zaktualizowano kurs'
      else
        render :edit
      end
    end

    private

    def course_params
      params.require(:course).permit(:name, :price, :seats, :starts_at, :ends_at, :description, :activity_type, :state, :instructor_id, :creator_id)
    end
  end
end

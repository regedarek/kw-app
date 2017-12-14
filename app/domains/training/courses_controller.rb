module Training
  class CoursesController < ApplicationController
    def index
      @courses = Training::Db::CourseRecord.all
    end

    def new
      @course = Training::Db::CourseRecord.new
    end

    def create
      @course = Training::Db::CourseRecord.new(course_params)

      if @course.save
        redirect_to training_courses_path, notice: 'Course created'
      else
        render :new
      end
    end

    def destroy
      @course.destroy
      redirect_to training_courses_path, notice: 'Course destroyed'
    end

    private

    def course_params
      params.require(:course).permit(:title, :description, :cost, :instructor)
    end
  end
end

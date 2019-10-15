module Business
  class CoursesController < ApplicationController
    append_view_path 'app/components'

    def index
      @q = Business::CourseRecord.includes(:instructor).ransack(params[:q])
      @q.sorts = 'starts_at asc' if @q.sorts.empty?
      @courses = @q.result(distinct: true)

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

    def show
      @course = Business::CourseRecord.find(params[:id])
    end

    def edit
      @course = Business::CourseRecord.find(params[:id])
    end

    def seats_minus
      @course = Business::CourseRecord.find(params[:id])
      @course.seats -= 1

      if @course.save
        redirect_to courses_path, notice: 'Zwolniono miejsce!'
      else
        redirect_to courses_path, alert: @course.errors.messages
      end
    end

    def seats_plus
      @course = Business::CourseRecord.find(params[:id])
      @course.seats += 1

      if @course.save
        redirect_to courses_path, notice: 'Zwolniono miejsce!'
      else
        redirect_to courses_path, alert: @course.errors.full_messages
      end
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
      params.require(:course).permit(:name, :price, :seats, :starts_at, :ends_at, :description, :activity_type, :state, :instructor_id, :max_seats, :sign_up_url, :creator_id)
    end
  end
end

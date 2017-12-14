module Training
  class CoursesController < ApplicationController
    def index
      @courses = Training::Db::CourseRecord.all
    end

    def new
      @course = Training::Db::CourseRecord.new
    end

    def show
      @course = Training::Db::CourseRecord.find(params[:id])
    end

    def create
      @course = Training::Db::CourseRecord.new(course_params)

      if @course.save
        redirect_to training_courses_path, notice: 'Course created'
      else
        render :new
      end
    end

    def new_participant
      @course = Training::Db::CourseRecord.find(params[:id])
      @participant = Training::Db::ParticipantRecord.new(course_id: @course.id)
    end

    def add_participant
      @course = Training::Db::CourseRecord.find(params[:id])
      @participant = Training::Db::ParticipantRecord.new(participant_params)
      @participant.course_id = @course.id

      if @participant.save
        redirect_to thanks_training_courses_path, notice: 'Participant added.'
      else
        render :new
      end
    end

    def thanks
    end

    def destroy
      @course.destroy
      redirect_to training_courses_path, notice: 'Course destroyed'
    end

    private

    def participant_params
      params.require(:participant)
        .permit(
          :full_name, :email, :phone, :prefered_time, :equipment, :height,
          :recommended_by, :kw_id, :birth_date, :birth_place
        )
    end

    def course_params
      params.require(:course).permit(:title, :description, :cost, :instructor)
    end
  end
end

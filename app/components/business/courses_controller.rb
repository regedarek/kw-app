module Business
  class CoursesController < ApplicationController
    append_view_path 'app/components'

    def index
      courses = if params[:archive]
        Business::CourseRecord.includes(:coordinator).all
      else
        Business::CourseRecord.includes(:coordinator).where('starts_at >= ?', Time.zone.now)
      end
      @q = courses.ransack(params[:q])
      @q.sorts = 'starts_at asc' if @q.sorts.empty?
      @courses = @q.result(distinct: true).page(params[:page])

      authorize! :read, Business::CourseRecord

      @course = Business::CourseRecord.new
    end

    def new
      @course = Business::CourseRecord.new
      @course.coordinator_id = current_user.id

      authorize! :create, Business::CourseRecord
    end

    def create
      @course = Business::CourseRecord.new(course_params)
      authorize! :create, Business::CourseRecord

      @course.creator_id = current_user.id
      @course.name = I18n.t("activerecord.attributes.business/course_record.activity_types.#{@course.activity_type}")

      if @course.save
        redirect_to courses_path(q: params.to_unsafe_h[:q]), notice: 'Dodano kurs'
      else
        render :new
      end
    end

    def show
      @course = Business::CourseRecord.friendly.find(params[:id])
      authorize! :read, Business::CourseRecord
    end

    def seats_minus
      @course = Business::CourseRecord.find(params[:id])
      @course.seats -= 1
      authorize! :manage, Business::CourseRecord

      if @course.save
        redirect_to courses_path(q: params.to_unsafe_h[:q]), notice: 'Zwolniono miejsce!'
      else
        redirect_to courses_path(q: params.to_unsafe_h[:q]), alert: @course.errors.messages
      end
    end

    def seats_plus
      @course = Business::CourseRecord.find(params[:id])
      @course.seats += 1

      authorize! :manage, Business::CourseRecord
      if @course.save
        redirect_to courses_path(q: params.to_unsafe_h[:q]), notice: 'Zwolniono miejsce!'
      else
        redirect_to courses_path(q: params.to_unsafe_h[:q]), alert: @course.errors.full_messages
      end
    end

    def edit
      @course = Business::CourseRecord.find(params[:id])
      authorize! :manage, Business::CourseRecord
    end

    def update
      @course = Business::CourseRecord.find(params[:id])
      authorize! :manage, Business::CourseRecord

      if @course.update(course_params)
        redirect_to edit_course_path(@course.id), notice: 'Zaktualizowano kurs'
      else
        render :edit
      end
    end

    def destroy
      @course = Business::CourseRecord.find(params[:id])
      @course.destroy
      authorize! :manage, Business::CourseRecord

      redirect_to courses_path(q: params.to_unsafe_h[:q]), notice: 'Usunięto kurs'
    end

    private

    def course_params
      params.require(:course).permit(:coordinator_id, :name, :price, :seats, :starts_at, :ends_at, :description, :activity_type, :state, :instructor_id, :max_seats, :sign_up_url, :creator_id, :event_id)
    end
  end
end

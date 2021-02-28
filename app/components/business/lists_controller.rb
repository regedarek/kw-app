module Business
  class ListsController < ApplicationController
    include EitherMatcher
    append_view_path 'app/components'

    def new
      @sign_up = Business::SignUpRecord.find(params[:id])
      @list = Business::ListRecord.new
      @alternative_courses = Business::CourseRecord
        .where('starts_at >= ?', Time.zone.now)
        .where('max_seats > seats')
        .where(
          state: 'ready',
          activity_type: @sign_up.course.activity_type
        )
        .where.not(id: @sign_up.course_id)
        .order(created_at: :desc)

      render layout: 'public'
    end

    def ask
      @sign_up = Business::SignUpRecord.find(params[:id])
      ::Business::SignUpMailer.list(@sign_up.id).deliver_later
    end

    def create
      @sign_up = Business::SignUpRecord.find(params[:id])
      @list = Business::ListRecord.new(list_params)
      @alternative_courses = Business::CourseRecord
        .where('starts_at >= ?', Time.zone.now)
        .where('max_seats > seats')
        .where(
          state: 'ready',
          activity_type: @sign_up.course.activity_type
        )
        .where.not(id: @sign_up.course_id)
        .order(created_at: :desc)

      if @list.save
        redirect_to public_course_path(@list.sign_up.course_id), notice: 'Wysłaliśmy twoje zapotrzebowanie na sprzęt. Po zatwierdzeniu twojego zapisu otrzymasz e-mail od koordynatora.'
      else
        render :new
      end
    end

    private

    def list_params
      params.require(:list).permit(:description, :sign_up_id, :birthplace, :birthdate, :rules, :alternative_email, course_ids: [])
    end
  end
end

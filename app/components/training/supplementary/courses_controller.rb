module Training
  module Supplementary
    class CoursesController < ApplicationController
      include EitherMatcher
      append_view_path 'app/components'

      def index
        @active_courses = Training::Supplementary::Repository.new.fetch_active_courses(category: params[:category], kind: params[:kind])
        @inactive_courses = Training::Supplementary::Repository.new.fetch_inactive_courses(category: params[:category], kind: params[:kind])
      end

      def archived
        @archived_courses = Kaminari.paginate_array(Training::Supplementary::Repository.new.fetch_archived_courses(category: params[:category], kind: params[:kind])).page(params[:page]).per(10)
      end

      def new
        @course = Training::Supplementary::CourseRecord.new
      end

      def show
        record = Training::Supplementary::CourseRecord.find(params[:id]) rescue Training::Supplementary::CourseRecord.find_by!(slug: params[:id])
        @course = Training::Supplementary::Course.from_record(record)
        @limiter = Training::Supplementary::Limiter.new(@course)
        @current_user_sign_up = Training::Supplementary::SignUpRecord.find_by(course_id: @course.id, user_id: current_user.id) if user_signed_in?
      end

      def edit
        @course = Training::Supplementary::CourseRecord.find(params[:id])
      end

      def create
        either(create_record) do |result|
          result.success do
            redirect_to wydarzenia_path, flash: { notice: 'Utworzono wydarzenie' }
          end

          result.failure do |errors|
            flash[:error] = errors.values.join(", ")
            render :new
          end
        end
      end

      def update
        @course = Training::Supplementary::CourseRecord.find(params[:id])

        if @course.update(course_params.merge(organizator_id: course_params[:organizator_id]&.first))
          redirect_to edit_supplementary_course_path(@course.id), notice: 'Course updated'
        else
          render :edit
        end
      end

      def destroy
        @course = Training::Supplementary::CourseRecord.find(params[:id])
        if @course.destroy
          redirect_to supplementary_courses_path, notice: 'Course destroyed'
        else
          redirect_to supplementary_courses_path, alert: 'Course not destroyed'
        end
      end

      private

      def create_record
        Training::Supplementary::CreateCourse.new(
          Training::Supplementary::Repository.new,
          Training::Supplementary::CreateCourseForm.new
        ).call(raw_inputs: course_params)
      end

      def course_params
        params
          .require(:course)
          .permit(
            :name, :slug, :place, :start_date, :kind, :end_date, :application_date, :price_kw, :baner,
            :price_non_kw, :remarks, :category, :price, :one_day, :active, :cash,
            :open, :packages, :limit, :last_fee_paid, organizator_id: []
          )
      end
    end
  end
end

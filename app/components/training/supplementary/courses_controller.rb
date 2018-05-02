module Training
  module Supplementary
    class CoursesController < ApplicationController
      include EitherMatcher
      append_view_path 'app/components'

      def index
        @courses = Training::Supplementary::Repository.new.fetch_courses
      end

      def new
        @course = Training::Supplementary::CourseRecord.new
      end

      def show
        @course = Training::Supplementary::CourseRecord.find(params[:id])
      end

      def edit
        @course = Training::Supplementary::CourseRecord.find(params[:id])
      end

      def create
        either(create_record) do |result|
          result.success do
            redirect_to supplementary_courses_path, flash: { notice: 'Utworzono wydarzenie' }
          end

          result.failure do |errors|
            flash[:error] = errors.values.join(", ")
            redirect_to new_supplementary_course_path
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
            :name, :place, :start_date, :end_date, :application_date, :price_kw,
            :price_non_kw, :remarks, :category, organizator_id: []
          )
      end
    end
  end
end

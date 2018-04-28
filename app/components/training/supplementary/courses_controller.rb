module Training
  module Supplementary
    class CoursesController < ApplicationController
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
        @course = Training::Supplementary::CourseRecord.new(course_params)

        if @course.save
          redirect_to supplementary_courses_path, notice: 'Course created'
        else
          render :new
        end
      end

      def update
        @course = Training::Supplementary::CourseRecord.find(params[:id])

        if @course.update(course_params)
          redirect_to supplementary_courses_path, notice: 'Course updated'
        else
          render :edit
        end
      end

      private

      def course_params
        params.require(:course).permit(:name)
      end
    end
  end
end

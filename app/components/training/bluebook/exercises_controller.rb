module Training
  module Bluebook
    class ExercisesController < ApplicationController
      include EitherMatcher
      append_view_path 'app/components'

      def new
        @exercise = Training::Bluebook::ExerciseRecord.new
      end

      def create
        @exercise = Training::Bluebook::ExerciseRecord.new(exercise_params)

        if @exercise.save
          redirect_to '/trening/skimo', notice: 'Dodano ćwiczenie'
        else
          render :new
        end
      end

      def show
        @exercise = Training::Bluebook::ExerciseRecord.find(params[:id])
      end

      private

      def exercise_params
        params.require(:exercise).permit(:name, :description, :group_type)
      end
    end
  end
end

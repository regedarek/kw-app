module Training
  module Supplementary
    class SignUpsController < ApplicationController
      def create
        course = Training::Supplementary::CourseRecord.find(params[:course_id])
        return redirect_to :back, alert: t('.limit_exceded') if course.limit > 0 && course.sign_ups.count >= course.limit

        Training::Supplementary::Repository.new.sign_up!(
          course_id: params[:course_id],
          user_id: current_user.id
        ) if user_signed_in?

        redirect_to :back, notice: 'Zapisałeś się!'
      end

      def destroy
        Training::Supplementary::SignUpRecord.find_by(course_id: params[:id], user_id: current_user.id)&.destroy

        redirect_to :back, notice: 'Wypisałeś się!'
      end
    end
  end
end

module Training
  module Supplementary
    class SignUpsController < ApplicationController
      def create
        course = Training::Supplementary::CourseRecord.find(params[:course_id])
        return redirect_to :back, alert: t('.limit_exceded') if course.limit > 0 && course.sign_ups.count >= course.limit
        fee = ::Db::Membership::Fee.find_by(kw_id: current_user.kw_id, year: Date.today.year)
        if course.last_fee_paid
          return redirect_to :back, alert: t('.not_last_fee') if !fee&.payment&.paid?
        end

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

module Training
  module Supplementary
    class SignUpsController < ApplicationController
      include EitherMatcher
      append_view_path 'app/components'

      def create
        either(create_record) do |result|
          result.success do
            redirect_to :back, notice: 'Zapisałeś się!'
          end

          result.failure do |errors|
            flash[:error] = errors.values.join(", ")
            redirect_to :back
          end
        end
      end

      def cancel
        sign_up = Training::Supplementary::SignUpRecord.find_by(code: params[:code])
        if sign_up.present?
          sign_up.destroy
          redirect_to supplementary_course_path(sign_up.course.id), notice: 'Wypisaliśmy Cię z wydarzenia!'
        else
          redirect_to supplementary_courses_path, alert: 'Nie znaleziono takiego zapisu, być może już się wypisałeś!'
        end
      end

      def destroy
        if user_signed_in? && (current_user.admin? || current_user.roles.include?('events'))
          Training::Supplementary::SignUpRecord.find(params[:id])&.destroy

          redirect_to :back, notice: 'Usunięto zapis!'
        else
          redirect_to :back, alert: 'Nie masz uprawnień!'
        end
      end

      private

      def create_record
        Training::Supplementary::CreateSignUp.new(
          Training::Supplementary::Repository.new,
          Training::Supplementary::CreateSignUpForm.new
        ).call(raw_inputs: sign_up_params)
      end

      def sign_up_params
        params.require(:sign_up).permit(:email, :user_id, :course_id)
      end
    end
  end
end

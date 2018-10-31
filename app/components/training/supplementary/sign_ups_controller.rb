module Training
  module Supplementary
    class SignUpsController < ApplicationController
      include EitherMatcher
      append_view_path 'app/components'

      def manually
        either(manually_sign_up) do |result|
          result.success do
            redirect_to :back, notice: 'Zapisałeś uczestnika i wysłałeś link do płatności!'
          end

          result.failure do |errors|
            flash[:error] = errors.values.join(", ")
            redirect_to :back
          end
        end
      end

      def create
        either(create_record) do |result|
          result.success do
            redirect_to :back, notice: 'Zapisałeś się!'
          end

          result.failure do |errors|
            flash[:error] = errors.map {|k,v| "#{SignUpRecord.human_attribute_name(k)} #{v.to_sentence}"}.join(', ')
            redirect_to :back
          end
        end
      end

      def cancel
        sign_up = Training::Supplementary::SignUpRecord.find_by(code: params[:code])
        if sign_up.present?
          sign_up.destroy

          redirect_to polish_event_path(sign_up.course.id), notice: 'Wypisaliśmy Cię z wydarzenia!'
        else
          redirect_to wydarzenia_path, alert: 'Nie znaleziono takiego zapisu, być może już się wypisałeś!'
        end
      end

      def send_email
        if user_signed_in? && (current_user.admin? || current_user.roles.include?('events'))
          sign_up = Training::Supplementary::SignUpRecord.find(params[:id])
          Training::Supplementary::SignUpMailer.sign_up(sign_up.id).deliver_later
          redirect_to polish_event_path(sign_up.course.id), notice: 'Wysłano e-mail z linkiem do płatności!'
        else
          redirect_to polish_event_path(sign_up.course.id), alert: 'Nie masz uprawnień!'
        end
      end

      def destroy
        if user_signed_in? && (current_user.admin? || current_user.roles.include?('events'))
          sign_up = Training::Supplementary::SignUpRecord.find(params[:id])
          if sign_up.present?
            Training::Supplementary::DestroySignUp.new(
              Training::Supplementary::Repository.new
            ).call(sign_up.id)
          end

          redirect_to :back, notice: 'Usunięto zapis!'
        else
          redirect_to :back, alert: 'Nie masz uprawnień!'
        end
      end

      private

      def manually_sign_up
        Training::Supplementary::ManuallySignUp.new(
          Training::Supplementary::Repository.new,
          Training::Supplementary::ManuallySignUpForm.new
        ).call(raw_inputs: manually_sign_up_params)
      end

      def create_record
        Training::Supplementary::CreateSignUp.new(
          Training::Supplementary::Repository.new,
          Training::Supplementary::CreateSignUpForm.new
        ).call(raw_inputs: sign_up_params)
      end

      def manually_sign_up_params
        params.require(:manually_sign_up).permit(:email, :course_id, :supplementary_course_package_type_id)
      end

      def sign_up_params
        params.require(:sign_up).permit(:name, :email, :user_id, :course_id, :supplementary_course_package_type_id)
      end
    end
  end
end

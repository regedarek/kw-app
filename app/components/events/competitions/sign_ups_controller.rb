module Events
  module Competitions
    class SignUpsController < ApplicationController
      include EitherMatcher
      append_view_path 'app/components'

      def index
        @competition = Events::Db::CompetitionRecord.find_by(id: params[:competition_id])
      end

      def new
        @competition = Events::Db::CompetitionRecord.find_by(id: params[:competition_id])
      end

      def create
        @competition = Events::Db::CompetitionRecord.find_by(id: params[:competition_id])
        either(create_record) do |result|
          result.success do
            redirect_to competition_sign_ups_path(params[:competition_id]), flash: { notice: 'Zapisano na zawody!' }
          end

          result.failure do |errors|
            flash[:error] = errors.values.join(", ")
            render(action: :new)
          end
        end
      end

      private

      def create_record
        Events::Competitions::SignUps::Create.new(
          Events::Competitions::Repository.new,
          Events::Competitions::SignUps::CreateForm.new
        ).call(competition_id: params[:competition_id], raw_inputs: sign_up_params)
      end

      def sign_up_params
        params
          .require(:sign_up)
          .permit(
            :participant_name_1,
            :participant_name_2,
            :participant_email_1,
            :participant_email_2,
            :participant_birth_year_1,
            :participant_birth_year_2,
            :participant_city_1,
            :participant_city_2,
            :participant_team_1,
            :participant_team_2,
            :participant_gender_1,
            :participant_gender_2,
            :competition_package_type_1_id,
            :competition_package_type_2_id,
            :remarks,
            :terms_of_service
          )
      end
    end
  end
end

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
        redirect_to competition_sign_ups_path(params[:competition_id]),
          flash: { alert: 'Zapisy zamknięte!' } if @competition.closed?
      end

      def create
        @competition = Events::Db::CompetitionRecord.find_by(id: params[:competition_id])

        either(create_record) do |result|
          result.success do
            redirect_to competition_sign_ups_path(params[:competition_id]), flash: { notice: 'Zapisano na zawody!' }
          end

          result.failure do |errors|
            @errors = errors
            @sign_up = Events::SignUp.new(params_for_build)
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

      def params_for_build
        {
          id: params[:id].to_i,
          competition_id: params[:competition_id].to_i,
          team_name: sign_up_params[:team_name],
          participant_name_1: sign_up_params[:participant_name_1],
          participant_name_2: sign_up_params[:participant_name_2],
          participant_kw_id_1: sign_up_params[:participant_kw_id_1],
          participant_kw_id_2: sign_up_params[:participant_kw_id_2],
          participant_email_1: sign_up_params[:participant_email_1],
          participant_email_2: sign_up_params[:participant_email_2],
          participant_birth_year_1: params[:sign_up][:participant_birth_year_1],
          participant_birth_year_2: params[:sign_up][:participant_birth_year_2],
          participant_city_1: sign_up_params[:participant_city_1],
          participant_city_2: sign_up_params[:participant_city_2],
          participant_team_1: sign_up_params[:participant_team_1],
          participant_team_2: sign_up_params[:participant_team_2],
          participant_gender_1: sign_up_params[:participant_gender_1],
          participant_gender_2: sign_up_params[:participant_gender_2],
          competition_package_type_1_id: sign_up_params[:competition_package_type_1_id].to_i,
          competition_package_type_2_id: sign_up_params[:competition_package_type_2_id].to_i,
          remarks: sign_up_params[:remarks],
          terms_of_service: ActiveRecord::Type::Boolean.new.deserialize(sign_up_params[:terms_of_service]),
          single: ActiveRecord::Type::Boolean.new.deserialize(sign_up_params[:single])
        }
      end

      def sign_up_params
        params
          .require(:sign_up)
          .permit(
            :team_name,
            :participant_name_1,
            :participant_name_2,
            :participant_gender_1,
            :participant_gender_2,
            :participant_email_1,
            :participant_email_2,
            :participant_kw_id_1,
            :participant_kw_id_2,
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
            :terms_of_service,
            :single
          )
      end
    end
  end
end

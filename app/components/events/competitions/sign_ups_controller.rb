module Events
  module Competitions
    class SignUpsController < ApplicationController
      include EitherMatcher
      append_view_path 'app/components'

      def index
        @competition = if slug_params.fetch(:name, nil)
          Events::Db::CompetitionRecord.find_by!(edition_sym: slug_params.fetch(:name))
        else
          Events::Db::CompetitionRecord.find_by!(id: params[:competition_id])
        end
      end

      def new
        @competition = Events::Db::CompetitionRecord.find_by(id: params[:competition_id])
        @sign_up = Events::Db::SignUpRecord.new
        redirect_to competition_sign_ups_path(params[:competition_id]),
          flash: { alert: t('.closed_or_limit_reached') } if @competition.closed_or_limit_reached?
      end

      def create
        @competition = Events::Db::CompetitionRecord.find_by(id: params[:competition_id])

        either(create_record(@competition.form)) do |result|
          result.success do
            @sign_up = Events::Db::SignUpRecord.new(sign_up_params)
            redirect_to competition_sign_ups_path(params[:competition_id]), flash: { notice: t('.success') }
          end

          result.failure do |errors|
            @errors = errors
            @sign_up = Events::Db::SignUpRecord.new(sign_up_params)
            render(action: :new)
          end
        end
      end

      def edit
        @competition = Events::Db::CompetitionRecord.find_by(id: params[:competition_id])
        @sign_up = Events::Db::SignUpRecord.find(params[:id])
        @team = false
        authorize! :update, Events::Db::SignUpRecord
      end

      def update
        @competition = Events::Db::CompetitionRecord.find_by(id: params[:competition_id])
        @sign_up = Events::Db::SignUpRecord.find(params[:id])

        authorize! :update, Events::Db::SignUpRecord

        either(update_record(@competition.form)) do |result|
          result.success do
            redirect_to edit_competition_sign_up_path(competition_id: params[:competition_id], id: @sign_up.id), flash: { notice: t('.success') }
          end

          result.failure do |errors|
            @errors = errors
            render(action: :edit)
          end
        end
      end

      def destroy
        sign_up = Events::Db::SignUpRecord.find(params[:id])

        authorize! :destroy, Events::Db::SignUpRecord

        sign_up.destroy

        redirect_back(fallback_location: root_path, notice: 'Usunięto zapis!')
      end

      def send_email
        sign_up = Events::Db::SignUpRecord.find(params[:id])

        Events::Competitions::SignUpMailer.sign_up(sign_up.id).deliver_later
        sign_up.update(sent_at: Time.zone.now)


        redirect_back(fallback_location: root_path, notice: 'Wysłano e-mail!')
      end

      private

      def create_record(form)
        Events::Competitions::SignUps::Create.new(
          Events::Competitions::Repository.new,
          form
        ).call(competition_id: params[:competition_id], raw_inputs: params[:sign_up])
      end

      def update_record(form)
        Events::Competitions::SignUps::Update.new(
          Events::Competitions::Repository.new,
          form
        ).call(competition_id: params[:competition_id], sign_up_record_id: params[:id], raw_inputs: params[:sign_up])
      end

      def slug_params
        params.permit(:name)
      end

      def sign_up_params
        params
          .require(:sign_up)
          .permit(
            :team_name,
            :participant_name_1,
            :participant_name_2,
            :participant_gender_1,
            :participant_phone_1,
            :participant_phone_2,
            :participant_gender_2,
            :license_number,
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
            :participant_country_1,
            :participant_country_2,
            :participant_license_id_1,
            :competition_package_type_1_id,
            :competition_package_type_2_id,
            :teammate_id,
            :rescuer,
            :friday_night,
            :saturday_night,
            :expired_at,
            :tshirt_size_1,
            :tshirt_size_2,
            :remarks,
            :single
          )
      end
    end
  end
end

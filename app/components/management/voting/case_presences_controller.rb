module Management
  module Voting
    class CasePresencesController < ApplicationController
      include EitherMatcher
      append_view_path 'app/components'

      def create
        authorize! :manage, Management::Voting::CasePresenceRecord

        @case_presence = Management::Voting::CasePresenceRecord.find_or_initialize_by(case_presence_params)

        @case_presence.cerber = current_user
        @case_presence.presence_date = '18-05-2022'.to_date
        @case_presence.accepted_terms = true

        if @case_presence.save
          redirect_to '/glosowania/obecni', notice: "Dodano!"
        else
          redirect_to '/glosowania/obecni', alert: "Nie Dodano!"
        end
      end

      def destroy
        @case_presence = Management::Voting::CasePresenceRecord.find(params[:id])

        @case_presence.destroy
        redirect_to '/glosowania/obecni', notice: "Usunięto!"
      end

      private

      def case_presence_params
        params
          .require(:case_presence)
          .permit(:user_id)
      end
    end
  end
end

module Management
  module Voting
    class VotesController < ApplicationController
      include EitherMatcher
      append_view_path 'app/components'

      def create
        authorize! :create, Management::Voting::VoteRecord

        either(create_record) do |result|
          result.success do |case_id|
            redirect_to case_path(case_id), flash: { notice: 'Zagłosowano' }
          end

          result.failure do |case_id|
            redirect_to case_path(case_id), flash: { alert: 'Twój głos nie został zapisany, gdyż czas na oddanie głosu już minął.' }
          end
        end
      end

      private

      def create_record
        Management::Voting::CreateVote.new(
          Management::Voting::VoteForm
        ).call(raw_inputs: vote_params, current_user_id: current_user.id)
      end

      def vote_params
        params
          .require(:vote)
          .permit(:case_id, :commission, :authorized_id, :user_id, :decision, user_ids: [])
      end
    end
  end
end

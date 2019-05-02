module Management
  module Voting
    class CasesController < ApplicationController
      include EitherMatcher
      append_view_path 'app/components'

      def index
        @cases = Management::Voting::CaseRecord.order(created_at: :desc)
      end

      def new
        authorize! :create, Management::Voting::CaseRecord
        @case_record = Management::Voting::CaseRecord.new
      end

      def create
        authorize! :create, Management::Voting::CaseRecord
        either(create_record) do |result|
          result.success do
            redirect_to cases_path, flash: { notice: 'Utworzono głosowanie' }
          end

          result.failure do |errors|
            @case_record = Management::Voting::CaseRecord.new(case_params)
            @errors = errors.map(&:to_sentence)
            render :new
          end
        end
      end

      def show
        @case = Management::Voting::CaseRecord.friendly.find(params[:id])
        @repository = Management::Voting::Repository.new
      end

      def approve
        case_record = Management::Voting::CaseRecord.find(params[:id])
        user = if user_signed_in?
                 current_user
               else
                 Db::User.find(params[:user_id])
               end
        case_record.votes.where(user_id: user.id).first_or_initialize.tap do |vote|
          vote.approved = true
          vote.save
        end if user

        redirect_to case_path(params[:id])
      end

      def unapprove
        case_record = Management::Voting::CaseRecord.find(params[:id])
        user = if user_signed_in?
                 current_user
               else
                 Db::User.find(params[:user_id])
               end
        case_record.votes.where(user_id: user.id).first_or_initialize.tap do |vote|
          vote.approved = false
          vote.save
        end if user

        redirect_to case_path(params[:id])
      end

      def destroy
        case_record = Management::Voting::CaseRecord.find(params[:id])
        authorize! :destroy, Management::Voting::CaseRecord

        case_record.destroy

        redirect_to cases_path
      end

      private

      def create_record
        Management::Voting::CreateCase.new(
          Management::Voting::CaseForm
        ).call(raw_inputs: case_params)
      end

      def case_params
        params
          .require(:case)
          .permit(:name, :destrciption, :creator_id, attachments: [])
      end
    end
  end
end

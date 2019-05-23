module Management
  module Voting
    class CasesController < ApplicationController
      include EitherMatcher
      append_view_path 'app/components'

      def index
        @cases = Management::Voting::CaseRecord.accessible_by(current_ability).order(created_at: :desc)
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
        authorize! :read, @case
        @repository = Management::Voting::Repository.new
      end

      def approve_for_all
        repository = Management::Voting::Repository.new
        case_record = Management::Voting::CaseRecord.find(params[:id])

        repository.management_users.each do |user|
          case_record.votes.where(user_id: user.id).first_or_initialize.tap do |vote|
            vote.decision = 'approved'
            vote.save
          end
        end

        if case_record.voting? && repository.approved?(case_record.id)
          case_record.finish!
          nr = Management::Voting::CaseRecord.where(state: 'finished', updated_at: Time.current.beginning_of_month..Time.current.end_of_month).count
          case_record.update number: "#{nr}/#{Time.current.month}/#{Time.current.year}"
        end

        redirect_to case_path(params[:id])
      end

      def approve
        repository = Management::Voting::Repository.new
        case_record = Management::Voting::CaseRecord.find(params[:id])
        user = if user_signed_in?
                 current_user
               else
                 Db::User.find(params[:user_id])
               end
        case_record.votes.where(user_id: user.id).first_or_initialize.tap do |vote|
          vote.decision = 'approved'
          vote.save
        end if user

        if case_record.voting? && repository.approved?(case_record.id)
          case_record.finish!
          nr = Management::Voting::CaseRecord.where(state: 'finished', updated_at: Time.current.beginning_of_month..Time.current.end_of_month).count
          case_record.update number: "#{nr}/#{Time.current.month}/#{Time.current.year}"
        end

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
          vote.decision = 'unapproved'
          vote.save
        end if user

        if case_record.voting? && repository.approved?(case_record.id)
          case_record.finish!
          nr = Management::Voting::CaseRecord.where(state: 'finished', updated_at: Time.current.beginning_of_month..Time.current.end_of_month).count
          case_record.update number: "#{nr}/#{Time.current.month}/#{Time.current.year}"
        end

        redirect_to case_path(params[:id])
      end

      def abstain
        repository = Management::Voting::Repository.new
        case_record = Management::Voting::CaseRecord.find(params[:id])
        user = if user_signed_in?
                 current_user
               else
                 Db::User.find(params[:user_id])
               end
        case_record.votes.where(user_id: user.id).first_or_initialize.tap do |vote|
          vote.decision = 'abstained'
          vote.save
        end if user

        if case_record.voting? && repository.approved?(case_record.id)
          case_record.finish!
          nr = Management::Voting::CaseRecord.where(state: 'finished', updated_at: Time.current.beginning_of_month..Time.current.end_of_month).count
          case_record.update number: "#{nr}/#{Time.current.month}/#{Time.current.year}"
        end

        redirect_to case_path(params[:id])
      end

      def hide
        case_record = Management::Voting::CaseRecord.find(params[:id])
        case_record.update hidden: true

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

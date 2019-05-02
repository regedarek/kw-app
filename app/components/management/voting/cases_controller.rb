module Management
  module Voting
    class CasesController < ApplicationController
      include EitherMatcher
      append_view_path 'app/components'

      def index
        @cases = Management::Voting::CaseRecord.order(created_at: :desc)
      end

      def new
        @case_record = Management::Voting::CaseRecord.new
      end

      def create
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

      private

      def create_record
        Management::Voting::CreateCase.new(
          Management::Voting::CaseForm
        ).call(raw_inputs: case_params)
      end

      def case_params
        params
          .require(:case)
          .permit(:name, :description, :creator_id)
      end
    end
  end
end

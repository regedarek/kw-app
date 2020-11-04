module Management
  module Voting
    class CommissionsController < ApplicationController
      include EitherMatcher
      append_view_path 'app/components'

      def new
        authorize! :create, Management::Voting::VoteRecord
        @commission_record = Management::Voting::CommissionRecord.new
      end

      def create
        authorize! :create, Management::Voting::VoteRecord
        either(create_record) do |result|
          result.success do
            redirect_to new_commission_path, flash: { notice: 'Upoważniono' }
          end

          result.failure do |errors|
            @commission_record = Management::Voting::CommissionRecord.new(commission_params)
            @errors = errors
            render :new
          end
        end
      end

      private

      def create_record
        Management::Voting::CreateCommission.new(
          Management::Voting::CommissionForm
        ).call(raw_inputs: commission_params)
      end

      def commission_params
        params
          .require(:commission)
          .permit(:owner_id, :authorized_id, :approval)
      end
    end
  end
end

module Training
  module Activities
    class ContractsController < ApplicationController
      include EitherMatcher
      append_view_path 'app/components'

      def index
        authorize! :read, Training::Activities::ContractRecord

        @contracts = Training::Activities::ContractRecord.all
      end

      def new
        authorize! :create, Training::Activities::ContractRecord

        @contract = ::Training::Activities::ContractRecord.new
      end

      def create
        authorize! :create, Training::Activities::ContractRecord
        @contract = ::Training::Activities::ContractRecord.new(contract_params)

        if @contract.save
          redirect_to activities_contracts_path, notice: 'Dodano kontrakt'
        else
          render :new
        end
      end

      private

      def contract_params
        params.require(:contract).permit(:name, :description, :score)
      end
    end
  end
end

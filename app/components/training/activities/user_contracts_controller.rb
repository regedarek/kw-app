module Training
  module Activities
    class UserContractsController < ApplicationController
      include EitherMatcher

      def create
        #authorize! :create, Training::Activities::UserContractRecord
        contract = ::Training::Activities::UserContractRecord.new(contract_params)
        contract.user = current_user

        if contract.save
          redirect_to activities_mountain_route_path(contract.route.id), notice: 'Przypisano kontrakt'
        else
          render :new
        end
      end

      private

      def contract_params
        params.require(:user_contract).permit(:route_id, :contract_id)
      end
    end
  end
end

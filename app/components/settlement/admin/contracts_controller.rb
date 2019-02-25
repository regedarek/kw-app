module Settlement
  module Admin
    class ContractsController < ::Admin::BaseController
      include EitherMatcher
      append_view_path 'app/components'

      def index
        authorize! :read, Settlement::ContractRecord

        @contracts = Settlement::ContractRecord.includes(:acceptor).all
      end

      def new
        authorize! :create, Settlement::ContractRecord
        @contract = Settlement::ContractRecord.new
      end

      def create
        authorize! :create, Settlement::ContractRecord

        either(create_record) do |result|
          result.success { |contract| redirect_to admin_contracts_path }

          result.failure do |errors|
            @contract = Settlement::ContractRecord.new(contract_params)
            flash[:error] = errors.values.join(", ")
            render :new
          end
        end
      end

      def edit
        authorize! :read, Settlement::ContractRecord

        @contract = Settlement::ContractRecord.find(params[:id])
      end

      def update
        authorize! :update, Settlement::ContractRecord

        either(update_record) do |result|
          result.success { |contract| redirect_to edit_admin_contract_path(contract.id) }

          result.failure do |errors|
            @contract = Settlement::ContractRecord.new(contract_params)
            flash[:error] = errors.values.join(", ")
            render :new
          end
        end
      end

      def accept
        authorize! :accept, Settlement::ContractRecord

        contract = Settlement::ContractRecord.find(params[:id])
        contract.accept!
        contract.update(acceptor_id: current_user.id)

        redirect_back(
          fallback_location: admin_contracts_path,
          notice: 'Zaakceptowano'
        )
      end

      private

      def create_record
        Settlement::CreateContract.new(
          Settlement::Repository.new,
          Settlement::ContractForm.new
        ).call(raw_inputs: contract_params, creator_id: current_user.id)
      end

      def update_record
        Settlement::UpdateContract.new(
          Settlement::Repository.new,
          Settlement::ContractForm.new
        ).call(id: params[:id], raw_inputs: contract_params)
      end

      def contract_params
        params
          .require(:contract)
          .permit(
            :title, :description, :cost, :state, attachments: []
          )
      end
    end
  end
end

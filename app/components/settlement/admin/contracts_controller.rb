module Settlement
  module Admin
    class ContractsController < ::Admin::BaseController
      include EitherMatcher
      append_view_path 'app/components'

      def index
        authorize! :read, Settlement::ContractRecord

        @q = Settlement::ContractRecord.accessible_by(current_ability).ransack(params[:q])
        @q.sorts = ['state desc', 'created_at desc'] if @q.sorts.empty?
        @contracts = @q.result(distinct: true).includes([:acceptor, :creator])
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

      def show
        @contract = Settlement::ContractRecord.find(params[:id])

        authorize! :read, @contract
      end

      def download_attachment
        send_file(
          params[:url],
          filename: params[:filename],
          disposition: 'attachment'
        )
      end

      def edit
        @contract = Settlement::ContractRecord.find(params[:id])
        authorize! :read, @contract
      end

      def update
        @contract = Settlement::ContractRecord.find(params[:id])
        authorize! :update, @contract

        either(update_record) do |result|
          result.success do |contract|
            redirect_to edit_admin_contract_path(contract.id), notice: 'Zaktualizowano'
          end

          result.failure do |errors|
            render :edit
          end
        end
      end

      def accept
        authorize! :accept, Settlement::ContractRecord

        contract = Settlement::ContractRecord.find(params[:id])
        contract.accept!
        contract.update(acceptor_id: current_user.id)

        office_king_ids = Db::User.where(":name = ANY(roles)", name: "office_king").map(&:id)
        contract_user_ids = contract.users.map(&:id)
        recepient_ids = (office_king_ids + contract_user_ids).uniq.reject{|id| id == current_user.id }
        recepient_ids.each do |id|
          NotificationCenter::NotificationRecord.create(
            recipient_id: id,
            actor_id: contract.acceptor_id,
            action: 'accepted_contract',
            notifiable_id: contract.id,
            notifiable_type: 'Settlement::ContractRecord'
          )
        end

        redirect_back(
          fallback_location: admin_contracts_path,
          notice: 'Zaakceptowano'
        )
      end

      def prepayment
        authorize! :prepayment, Settlement::ContractRecord

        contract = Settlement::ContractRecord.find(params[:id])
        contract.prepayment!

        contract_user_ids = contract.users.map(&:id)
        recepient_ids = contract_user_ids.uniq.reject{|id| id == current_user.id }
        recepient_ids.each do |id|
          NotificationCenter::NotificationRecord.create(
            recipient_id: id,
            actor_id: current_user.id,
            action: 'prepayment_contract',
            notifiable_id: contract.id,
            notifiable_type: 'Settlement::ContractRecord'
          )
        end

        redirect_back(
          fallback_location: admin_contracts_path,
          notice: 'Rozliczono!'
        )
      end

      private

      def create_record
        Settlement::CreateContract.new(
          Settlement::Repository.new,
          Settlement::ContractForm
        ).call(raw_inputs: contract_params, creator_id: current_user.id)
      end

      def update_record
        Settlement::UpdateContract.new(
          Settlement::Repository.new,
          Settlement::ContractForm
        ).call(id: params[:id], raw_inputs: contract_params)
      end

      def contract_params
        params
          .require(:contract)
          .permit(
            :group_type, :period_date, :financial_type, :document_type, :document_date, :title, :description, :cost, :state, contractor_name: [], attachments: [], users_names: []
          )
      end
    end
  end
end

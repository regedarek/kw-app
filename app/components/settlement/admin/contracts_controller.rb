module Settlement
  module Admin
    class ContractsController < ::Admin::BaseController
      include EitherMatcher
      append_view_path 'app/components'

      def index
        authorize! :read, Settlement::ContractRecord

        @q = Settlement::ContractRecord.accessible_by(current_ability)
        @q = @q.where.not(state: ['closed']) unless params[:q]
        @q = @q.ransack(params[:q])
        @q.sorts = ['state desc', 'created_at desc'] if @q.sorts.empty?
        @contracts = @q.result(distinct: true).includes([:acceptor, :creator])
      end

      def analiza
        authorize! :analiza, Settlement::ContractRecord
        start_date = Date.new(params[:year].to_i, 1, 1)
        end_date = Date.new(params[:year].to_i, 12, 31)

        @contracts = Settlement::ContractRecord.where(document_date: start_date..end_date)
      end

      def new
        authorize! :create, Settlement::ContractRecord

        @contract = Settlement::ContractRecord.new(user_ids: [current_user.id])
        session[:original_referrer] = request.env["HTTP_REFERER"]
      end

      def create
        authorize! :create, Settlement::ContractRecord

        either(create_record) do |result|
          result.success { |contract| redirect_to admin_contracts_path }

          result.failure do |errors|
            @contract = Settlement::ContractRecord.new(contract_params)
            @errors = errors
            render :new
          end
        end
      end

      def show
        @contract = Settlement::ContractRecord.find(params[:id])

        authorize! :read, @contract
        session[:original_referrer] = request.env["HTTP_REFERER"]
      end

      def destroy
        authorize! :destroy, Settlement::ContractRecord

        contract = Settlement::ContractRecord.find(params[:id])
        contract.destroy

        redirect_back(
          fallback_location: admin_contracts_path,
          notice: 'Usunięto!'
        )
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
        session[:original_referrer] = request.env["HTTP_REFERER"]
      end

      def update
        @contract = Settlement::ContractRecord.find(params[:id])
        authorize! :update, @contract

        either(update_record) do |result|
          result.success do |contract|
            redirect_to edit_admin_contract_path(contract.id), notice: 'Zaktualizowano'
          end

          result.failure do |errors|
            @errors = errors
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
          notice: 'Zaakceptowano!'
        )
      end

      def prepayment
        authorize! :prepayment, Settlement::ContractRecord

        contract = Settlement::ContractRecord.find(params[:id])
        contract.prepayment!
        contract.update(preclosed_date: Time.current)

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

      def finish
        contract = Settlement::ContractRecord.find(params[:id])
        contract.finish!

        redirect_back(
          fallback_location: admin_contracts_path,
          notice: 'Rozliczono!'
        )
      end

      private

      def create_record
        Settlement::CreateContract.new(
          Settlement::Repository.new,
          Settlement::NewContractForm
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
            :group_type, :payout_type, :acceptor_id, :event_id, :period_date,
            :substantive_type, :financial_type, :document_type, :area_type, :event_type, :document_date, :activity_type,
            :title, :description, :cost, :state, :document_number, :internal_number, :checker_id,
            :contractor_id, attachments: [], event_ids: [], user_ids: [], project_ids: []
          )
      end
    end
  end
end

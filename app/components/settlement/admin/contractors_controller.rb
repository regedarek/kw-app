module Settlement
  module Admin
    class ContractorsController < ::Admin::BaseController
      include EitherMatcher
      append_view_path 'app/components'

      def new
        authorize! :create, Settlement::ContractorRecord

        @contractor = Settlement::ContractorRecord.new
      end

      def create
        authorize! :create, Settlement::ContractorRecord

        either(create_record) do |result|
          result.success { |contract| redirect_to admin_contracts_path }

          result.failure do |errors|
            @contractor = Settlement::ContractorRecord.new(contractor_params)
            flash[:error] = errors.values.join(", ")
            render :new
          end
        end
      end

      private

      def create_record
        Settlement::CreateContractor.new(
          Settlement::Repository.new,
          Settlement::ContractorForm
        ).call(raw_inputs: contractor_params)
      end

      def contractor_params
        params
          .require(:contractor)
          .permit(:name, :description, :nip)
      end
    end
  end
end

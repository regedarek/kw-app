module Settlement
  module Api
    class ContractorsController < ::Admin::BaseController
      def index
        contractors = Settlement::ContractorRecord.ransack(name_cont: params[:q]).result

        render json: contractors, code: 200
      end
    end
  end
end

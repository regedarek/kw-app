module Training
  module Activities
    module Api
      class BoarsController < ApplicationController
        include Pagy::Backend
        after_action { pagy_headers_merge(@pagy) if @pagy }

        def index
          monthly_users = ::Activities::SkiRepository.new.fetch_current_month

          render json: monthly_users.limit(5), status: :ok
        end
      end
    end
  end
end

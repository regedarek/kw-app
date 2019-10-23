module Management
  module Snw
    module Api
      class SnwAppliesController < ApplicationController
        def index
          snw_applies = Management::Snw::SnwApplyRecord.all

          render json: snw_applies.to_json
        end
      end
    end
  end
end

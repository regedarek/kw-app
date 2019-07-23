module Management
  module News
    class InformationsController < ApplicationController
      append_view_path 'app/components'

      def index
        @informations = InformationRecord.order(created_at: :desc).all
      end
    end
  end
end

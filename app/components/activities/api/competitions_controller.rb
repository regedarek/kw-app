module Activities
  module Api
    class CompetitionsController < ApplicationController
      append_view_path 'app/components'

      def index
        competitions_table = Activities::CompetitionsTable.new

        render json: render_to_string(partial: "activities/api/competitions/table", locals: { table: competitions_table }), format: :json
      end
    end
  end
end

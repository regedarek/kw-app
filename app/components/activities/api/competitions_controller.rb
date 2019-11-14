module Activities
  module Api
    class CompetitionsController < ApplicationController
      def index
        competitions_table = Activities::CompetitionsTable.new.call(country: params[:country] || :all)

        render json: competitions_table
      end
    end
  end
end

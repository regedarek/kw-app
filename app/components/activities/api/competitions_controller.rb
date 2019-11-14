module Activities
  module Api
    class CompetitionsController < ApplicationController
      def index
        competitions_table = Activities::CompetitionsTable.new(params[:country] || :all).call

        render json: competitions_table
      end
    end
  end
end

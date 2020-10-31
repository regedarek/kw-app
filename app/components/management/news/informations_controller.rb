module Management
  module News
    class InformationsController < ApplicationController
      append_view_path 'app/components'

      def index
        @informations = InformationRecord.order(created_at: :desc).all
      end

      def new
        @information = InformationRecord.new
      end

      def create
        @information = InformationRecord.new(information_params)
        if @information.save
          redirect_to '/informacje', notice: 'Dodano informację'
        else
          render :new
        end
      end
    end
  end
end

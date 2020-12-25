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

        authorize! :create, @information

        if @information.save
          redirect_to '/informacje', notice: 'Dodano informację'
        else
          render :new
        end
      end

      def show
        @information = InformationRecord.find(params[:id])
      end

      def edit
        @information = InformationRecord.find(params[:id])
      end

      def update
        @information = InformationRecord.find(params[:id])

        authorize! :manage, @information

        if @information.update(information_params)
          redirect_to "/informacje/#{@information.id}", notice: 'Zaktualizowano informację'
        else
          render :edit
        end
      end

      private

      def information_params
        params.require(:information).permit(:name, :description, :news_type, :group_type, :starred, :web, :url)
      end
    end
  end
end

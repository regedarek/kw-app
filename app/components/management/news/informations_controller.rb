module Management
  module News
    class InformationsController < ApplicationController
      append_view_path 'app/components'

      def index
        @informations = InformationRecord.order(starred: :desc, created_at: :desc).all
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
        @information = InformationRecord.friendly.find(params[:id])
      end

      def edit
        @information = InformationRecord.friendly.find(params[:id])
      end

      def update
        @information = InformationRecord.friendly.find(params[:id])

        authorize! :manage, @information

        if @information.update(information_params)
          redirect_to "/informacje/#{@information.slug}", notice: 'Zaktualizowano informację'
        else
          render :edit
        end
      end

      private

      def information_params
        params.require(:information).permit(:name, :description, :news_type, :group_type, :starred, :web, :url, attachments: [])
      end
    end
  end
end

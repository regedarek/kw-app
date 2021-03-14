module Shop
  module Api
    class ItemsController < ApplicationController
      append_view_path 'app/components'

      def index
        items = Shop::ItemRecord.all

        render json: items
      end

      def show
        item = Shop::ItemRecord.friendly.find(params[:id])

        render json: item
      end

      def create
        item = Shop::ItemRecord.new(item_params)

        if item.save
          render json: item, code: 201
        else
          render json: item.errors, code: 400
        end
      end

      def update
        item = Shop::ItemRecord.find(params[:id])

        if item.update(item_params)
          render json: item, code: 200
        else
          render json: item.errors, code: 400
        end
      end

      private

      def item_params
        params.require(:item).permit(:name, :description, :price)
      end
    end
  end
end

module Shop
  module Api
    class ItemsController < ApplicationController
      def index
        items = Shop::ItemRecord.all

        render json: items, code: 200, each_serializer: Shop::ItemSerializer
      end

      def show
        item = Shop::ItemRecord.friendly.find(params[:id])

        render json: item, serializer: Shop::ItemSerializer
      end

      def create
        item = Shop::ItemRecord.new(item_params)

        if item.save
          render json: item, code: 201, serializer: Shop::ItemSerializer
        else
          render json: item.errors, code: 400
        end
      end

      def update
        item = Shop::ItemRecord.find(params[:id])

        if item.update(item_params)
          render json: item, code: 200, serializer: Shop::ItemSerializer
        else
          render json: item.errors, code: 400
        end
      end

      def destroy
        item = Shop::ItemRecord.find(params[:id])

        item.destroy
        render json: item, serializer: Shop::ItemSerializer
      end

      private

      def item_params
        params.require(:item).permit(:name, :description, :price, item_kinds_attributes: [:name, :quantity])
      end
    end
  end
end

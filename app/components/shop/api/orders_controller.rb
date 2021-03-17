module Shop
  module Api
    class OrdersController < ApplicationController
      def create
        order = Shop::OrderRecord.new(order_params)

        if order.save
          render json: order, code: 201, serializer: Shop::OrderSerializer
        else
          render json: order.errors, code: 400
        end
      end

      private

      def order_params
        params.require(:order).permit(:user_id, order_items_attributes: [:id, :item_id, :user_id, :item_kind_id])
      end
    end
  end
end

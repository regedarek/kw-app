module Shop
  module Admin
    class OrdersController < ApplicationController
      append_view_path 'app/components'

      def index
        @orders = ::Shop::OrderRecord.includes(:user, :order_items, :items, :payment).all
      end

      def show
        @order = ::Shop::OrderRecord.find(params[:id])
      end

      def close
        order = ::Shop::OrderRecord.find(params[:id])
        order.close!

        redirect_to shop_admin_orders_path, notice: 'Zamknięto'
      end
    end
  end
end

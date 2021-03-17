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
    end
  end
end

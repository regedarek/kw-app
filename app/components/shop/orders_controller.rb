module Shop
  class OrdersController < ApplicationController
    append_view_path 'app/components'

    def index
      @orders = current_user.orders
    end

    def show
      @order = current_user.orders.find(params[:id])
    end
  end
end

module Shop
  module Admin
    class ItemsController < ApplicationController
      append_view_path 'app/components'

      def index
        @items = ::Shop::ItemRecord.all
      end

      def show
        @item = ::Shop::ItemRecord.find(params[:id])
      end

      def destroy
        @item = ::Shop::ItemRecord.find(params[:id])
        @item.destroy

        redirect_to '/sklepik-admin'
      end
    end
  end
end

module Shop
  class ItemsController < ApplicationController
    append_view_path 'app/components'

    def admin
      render "pages/shop_admin"
    end

    def index
      @items = Shop::ItemRecord.published
    end

    def show
      @item = Shop::ItemRecord.friendly.find(params[:id])
    end

    def new
      @item = Shop::ItemRecord.new
    end

    def create
      @item = Shop::ItemRecord.new(item_params)

      if @item.save
        redirect_to items_path, notice: 'Dodano'
      else
        render :new
      end
    end

    def edit
      @item = Shop::ItemRecord.friendly.find(params[:id])
    end

    def update
      @item = Shop::ItemRecord.find(params[:id])

      if @item.update(item_params)
        redirect_to item_path(@item.id), notice: 'Dodano'
      else
        render :edit
      end
    end

    private

    def item_params
      params.require(:item).permit(:name, :description)
    end
  end
end

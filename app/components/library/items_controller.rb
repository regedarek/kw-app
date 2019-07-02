module Library
  class ItemsController < ApplicationController
    include EitherMatcher
    append_view_path 'app/components'

    def index
      @items = ::Library::ItemRecord.all
    end

    def show
      @item = Library::ItemRecord.find(params[:id])
    end

    def new
      @item = Library::ItemRecord.new
    end

    def create
      @item = Library::ItemRecord.new(item_params)

      if @item.save
        redirect_to library_items_path, notice: 'Egzemplarz dodany!'
      else
        render :new
      end
    end

    private

    def item_params
      params.require(:item).permit(:title, :description)
    end
  end
end

module Library
  class ItemsController < ApplicationController
    include EitherMatcher
    append_view_path 'app/components'

    def index
      @q = ::Library::ItemRecord.ransack(params[:q])
      @q.sorts = 'created_at desc' if @q.sorts.empty?
      @items = @q.result.includes(:authors).page(params[:page]).per(20)
    end

    def show
      @item = Library::ItemRecord.friendly.find(params[:id])
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

    def edit
      @item = Library::ItemRecord.friendly.find(params[:id])
    end

    def update
      @item = Library::ItemRecord.find(params[:id])

      if @item.update(item_params)
        redirect_to edit_library_item_path(@item), notice: 'Egzemplarz dodany!'
      else
        render :edit
      end
    end

    private

    def item_params
      params.require(:item).permit(:title, :description, :doc_type, :autors, :publishment_at, :autors, :item_id, :reading_room, authors_names: [], attachments: [])
    end
  end
end

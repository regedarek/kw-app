module Library
  class ItemsController < ApplicationController
    include EitherMatcher
    append_view_path 'app/components'
    before_action :authenticate_user!

    def index
      redirect_to root_path, alert: "Musisz być aktywnym członkiem klubu" unless Membership::Activement.new(user: current_user).active?

      @q = ::Library::ItemRecord.ransack(params[:q])
      @q.sorts = 'updated_at desc' if @q.sorts.empty?
      @items = @q.result.page(params[:page]).per(20)
    end

    def show
      redirect_to root_path, alert: "Musisz być aktywnym członkiem klubu" unless Membership::Activement.new(user: current_user).active?

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
      redirect_to root_path, alert: "Musisz być aktywnym członkiem klubu" unless Membership::Activement.new(user: current_user).active?

      @item = Library::ItemRecord.friendly.find(params[:id])
    end

    def update
      redirect_to root_path, alert: "Musisz być aktywnym członkiem klubu" unless Membership::Activement.new(user: current_user).active?

      @item = Library::ItemRecord.find(params[:id])

      if @item.update(item_params)
        redirect_to edit_library_item_path(@item), notice: 'Egzemplarz dodany!'
      else
        render :edit
      end
    end

    def destroy
      @item = Library::ItemRecord.find(params[:id])
      @item.destroy

      redirect_to library_items_path, notice: 'Usunięto!'
    end

    private

    def item_params
      params.require(:item).permit(:title, :description, :doc_type, :autors, :publishment_at, :autors, :item_id, :reading_room, authors_names: [], attachments: [], tag_ids: [])
    end
  end
end

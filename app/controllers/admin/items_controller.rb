require 'admin/items'
require 'admin/items_form'
require 'items/owner_presenter'

module Admin
  class ItemsController < Admin::BaseController
    def index
      items = Db::Item.order(:rentable_id)
      items = items.send(params[:owner]) if params[:owner]
      @items = items.filter(filterable_params).page(params[:page])
    end

    def create
      result = Admin::Items.new(item_params).create
      result.success { redirect_to admin_items_path, notice: 'Dodano' }
      result.invalid { |form:| redirect_to admin_items_path, alert: "Nie dodano: #{form.errors.messages}" }
      result.else_fail!
    end

    def edit
      @item = Db::Item.find(params[:id])
    end

    def update_editable
      item = Db::Item.find(params[:id])
      item.update(item_params)
      render partial: 'admin/items/item_row', locals: { item: item }
    end

    def update
      result = Admin::Items.new(item_params).update(params[:id])
      result.success do |item:|
        redirect_to edit_admin_item_path(params[:id]), notice: 'Zaktualizowano'
        render partial: 'admin/items/item_row', locals: { item: item }
      end
      result.invalid { |form:| redirect_to edit_admin_item_path(params[:id]), alert: "Nie zaktualizowano bo: #{form.errors.messages}" }
      result.else_fail!
    end

    def destroy
      result = Admin::Items.destroy(params[:id])
      result.success { redirect_to :back, notice: 'Usunieto' }
      result.failure { redirect_to :back, alert: 'Nie usunieto' }
      result.else_fail!
    end

    def update_owner
      item = Db::Item.find(params[:id])
      item.update_column(:owner, params[:db_item].fetch(:owner).to_i)

      render partial: 'admin/items/item_row', locals: { item: item }
    end

    def toggle_rentable
      item = Db::Item.find(params[:id])
      item.toggle!(:rentable)
      
      render partial: 'admin/items/item_row', locals: { item: item }
    end

    private

    def filterable_params
      params.fetch('admin_items_form', {}).slice(:display_name, :rentable_id)
    end

    def item_params
      params.require(:admin_items_form).permit(:rentable_id, :display_name, :cost, :description, :owner, :rentable)
    end
  end
end

require 'admin/items'
require 'admin/items_form'
require 'items/owner_presenter'

module Admin
  class ItemsController < Admin::BaseController
    def index
      @q = Db::Item.ransack(params[:q])
      @q.sorts = 'rentable_id asc' if @q.sorts.empty?
      @items = @q.result.page(params[:page])
    end

    def create
      result = Admin::Items.new(item_params).create
      result.success { redirect_to admin_items_path, notice: 'Dodano' }
      result.invalid { |form:| redirect_to admin_items_path, alert: "Nie dodano: #{form.errors.messages}" }
      result.else_fail!
    end

    def show
      @item = Db::Item.find(params[:id])
      if params[:all]
        @reservations = Db::Item.find(params[:id]).reservations
      else
        @reservations = Db::Item.find(params[:id]).reservations.not_reserved
      end
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
        if request.xhr?
          render partial: 'admin/items/item_row', locals: { item: item }
        else
          redirect_to edit_admin_item_path(params[:id]), notice: 'Zaktualizowano'
        end
      end
      result.invalid { |form:| redirect_to edit_admin_item_path(params[:id]), alert: "Nie zaktualizowano bo: #{form.errors.messages}" }
      result.else_fail!
    end

    def destroy
      result = Admin::Items.destroy(params[:id])
      result.success { redirect_back(fallback_location: root_path, notice: 'Usunieto') }
      result.failure { redirect_back(fallback_location: root_path, alert: 'Nie usunieto') }
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

    def authorize_admin
      redirect_to root_url, alert: 'Nie jestes administratorem!' unless user_signed_in? && (current_user.roles.include?('reservations') || current_user.admin?)
    end

    def item_params
      params.require(:admin_items_form).permit(:rentable_id, :display_name, :cost, :description, :owner, :rentable)
    end
  end
end

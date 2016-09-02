module Admin
  class ItemsController < Admin::BaseController
    def index
      items = Db::Item.order(:id)
      @items = if params[:owner]
                 items.send(params[:owner])
               else
                 items
               end
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

    def update
      result = Admin::Items.new(item_params).update(params[:id])
      result.success { redirect_to edit_admin_item_path(params[:id]), notice: 'Zaktualizowano' }
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

      redirect_to :back, notice: "Ustawiono wlasciciela przedmiotu na #{::Items::OwnerPresenter.new(item.owner).to_s}"
    end

    def make_rentable
      Db::Item.find(params[:id]).update(rentable: true)
      redirect_to :back, notice: 'Udostepniono'
    end

    def make_urentable
      Db::Item.find(params[:id]).update(rentable: false)
      redirect_to :back, notice: 'Zablokowano udostepnianie'
    end

    private

    def item_params
      params.require(:admin_items_form).permit(:name, :cost, :description, :rentable, :owner)
    end
  end
end

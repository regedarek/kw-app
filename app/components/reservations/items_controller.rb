module Reservations
  class ItemsController < Admin::BaseController
    include EitherMatcher

    def update
      either(update_items) do |result|
        result.success do
          redirect_to edit_admin_reservation_path(params[:id]), notice: 'Zmieniłeś przedmioty rezerwacji!'
        end

        result.failure do |errors|
          flash[:error] = errors.values.join(", ")
          redirect_to :back
        end
      end
    end

    private

    def authorize_admin
      redirect_to root_url, alert: 'Nie jestes administratorem!' unless user_signed_in? && (current_user.roles.include?('reservations') || current_user.admin?)
    end

    def update_items
      Reservations::UpdateItems.new(
        Reservations::UpdateItemsForm.new
      ).call(raw_inputs: update_items_params)
    end

    def update_items_params
      params.require(:reservation).permit(:id, :items_ids)
    end
  end
end

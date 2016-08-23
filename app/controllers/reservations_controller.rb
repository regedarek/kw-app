class ReservationsController < ApplicationController
  def index
    @available_items = Availability::Items.new(start_date: params[:start_date]).collect
  end

  def availability
    redirect_to reservations_path(start_date: params.fetch('availability_form').fetch('start_date'))
  end

  def create
    reservation_params_from_url = HashWithIndifferentAccess.new(
      kw_id: current_user.kw_id,
      item_ids: [params[:item_id]],
      start_date: params[:start_date],
      end_date: (params[:start_date].to_date + 7)
    )
    result = Reservations::Reserve.new(reservation_params_from_url).create
    #result = Reservations::CreateReservation.from_params(reservation_params_from_url)
    result.success { redirect_to reservations_path(start_date: params[:start_date]), notice: 'Zarezerwowano' }
    result.invalid { |form:| redirect_to home_path, alert: "Nie dodano: #{form.errors.messages}" }
    result.invalid_period { |message:| redirect_to home_path, alert: message }
    result.else_fail!
  end

  def remove_item
    reservation = current_user.reservations.find(params[:id])
    item = Db::Item.find(params[:item_id])
    reservation.items.delete(item)
    #Reservations::RemoveItem.from(reservation_id: params[:id]).delete(item_id: params[:item_id])
    redirect_to :back, notice: 'Zrezygnowano'
  end

  private

  def reservation_params
    params.require(:reservations_form).permit(:kw_id, :item_ids, :start_date, :end_date)
  end
end

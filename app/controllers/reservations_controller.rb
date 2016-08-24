class ReservationsController < ApplicationController
  def index
    guarded_date = Guards::Date.new(date: params[:start_date])
    return redirect_to reservations_path(start_date: guarded_date.nearest_thursday) unless guarded_date.thursday?
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
    result = Reservations::CreateReservation.from(params: reservation_params_from_url)
    result.success { redirect_to reservations_path(start_date: params[:start_date]), notice: 'Zarezerwowano' }
    result.invalid { |form:| redirect_to home_path, alert: "Nie dodano: #{form.errors.messages}" }
    result.invalid_period { |message:| redirect_to home_path, alert: message }
    result.else_fail!
  end

  def delete_item
    result = Reservations::DeleteItem.from(reservation_id: params[:id]).delete(item_id: params[:item_id])
    result.success do |start_date:|
      redirect_to reservations_path(start_date: start_date), notice: 'Zrezygnowano'
    end
  end

  private

  def reservation_params
    params.require(:reservations_form).permit(:kw_id, :item_ids, :start_date, :end_date)
  end
end

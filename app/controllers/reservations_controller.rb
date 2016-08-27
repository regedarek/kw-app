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
    form = Reservations::Form.new(params[:reservations_form])
    result = Reservations::CreateReservation.create(form: form, user: current_user)
    result.success { redirect_to reservations_path(start_date: form.start_date.to_s), notice: 'Zarezerwowano' }
    result.form_invalid { |form:| redirect_to home_path, alert: "Nie dodano: #{form.errors.messages}" }
    result.else_fail!
  end

  def delete_item
    result = Reservations::CancelItem.from(reservation_id: params[:id]).delete(item_id: params[:item_id])
    result.success do |start_date:|
      redirect_to reservations_path(start_date: start_date), notice: 'Zrezygnowano'
    end
  end
end

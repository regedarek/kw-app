class ReservationsController < ApplicationController
  def index
   redirect_to new_reservation_path, alert: 'Czasowo wypożyczalnia online została zamknięta' unless current_user.admin?

   guarded_date = Guards::Date.new(date: params[:start_date])
   return redirect_to reservations_path(start_date: guarded_date.nearest_thursday) unless guarded_date.thursday?
   @available_items = Availability::Items.new(start_date: params[:start_date]).collect
  end

  def availability
    redirect_to new_reservation_path, alert: 'Czasowo wypożyczalnia online została zamknięta' unless current_user.admin?

    redirect_to reservations_path(start_date: params.fetch('availability_form').fetch('start_date'))
  end

  def create
  redirect_to new_reservation_path, alert: 'Czasowo wypożyczalnia online została zamknięta' unless current_user.admin?

   form = Reservations::Form.new(params[:reservations_form])
   result = Reservations::CreateReservation.create(form: form, user: current_user)
   result.success { redirect_to reservations_path(start_date: form.start_date.to_s), notice: 'Zarezerwowano przedmiot.' }
   result.form_invalid { |form:| redirect_to home_path, alert: "Nie dodano z powodu: #{form.errors.messages}" }
   result.item_already_reserved { |form:| redirect_to reservations_path(start_date: form.start_date.to_s), alert: 'Przedmiot został już zarezerwowany w tym okresie.'}
   result.else_fail!
  end

  def delete_item
    result = Reservations::CancelItem.from(reservation_id: params[:id]).delete(item_id: params[:item_id])
    result.success do |start_date:|
      redirect_to reservations_path(start_date: start_date), notice: 'Zrezygnowano z rezerwacji przedmiotu.'
    end
    result.item_not_exist { redirect_to :back, alert: 'Przedmiot nie istnieje.' }
    result.reservation_not_exist { redirect_to :back, alert: 'Przedmiot nie istnieje.' }
    result.else_fail!
  end
end

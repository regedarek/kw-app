module Library
  class ItemReservationsController < ApplicationController
    append_view_path 'app/components'

    def index
      @q = Library::ItemReservationRecord.includes(:item, :user, :back_by).ransack(params[:q])
      @q.sorts = 'back_at desc' if @q.sorts.empty?
      @reservations = @q.result.page(params[:page]).per(20)
    end

    def create
      reservation = Library::ItemReservationRecord.new(reservation_params)

      if reservation.save
        reservation.item.touch
        redirect_to library_item_path(reservation.item_id), notice: 'Dodano'
      else
        redirect_to library_item_path(reservation.item_id), alert: 'Problem'
      end
    end

    def return
      reservation = Library::ItemReservationRecord.find(params[:id])

      if reservation.update(back_at: Time.now, back_by: current_user)
        reservation.item.touch
        redirect_to library_item_path(reservation.item_id), notice: 'Zwrócono!'
      else
        redirect_to library_item_path(reservation.item_id), alert: 'Problem'
      end
    end

    def destroy
      reservation = Library::ItemReservationRecord.find(params[:id])

      if reservation.destroy
        redirect_to library_item_path(reservation.item_id), notice: 'Usunięto'
      else
        redirect_to library_item_path(reservation.item_id), alert: 'Problem'
      end
    end


    def remind
      reservation = Library::ItemReservationRecord.find(params[:id])

      ReservationMailer.remind_library_item(reservation).deliver_later

      redirect_to library_item_path(reservation.item_id), notice: 'Przypomniano!'
    end

    private

    def reservation_params
      params.require(:library_item_reservation).permit(:item_id, :user_id, :received_at, :returned_at, :description)
    end
  end
end

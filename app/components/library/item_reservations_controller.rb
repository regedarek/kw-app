module Library
  class ItemReservationsController < ApplicationController
    append_view_path 'app/components'

    def create
      reservation = Library::ItemReservationRecord.new(reservation_params)

      if reservation.save
        redirect_to library_item_path(reservation.item_id), notice: 'Dodano'
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

    private

    def reservation_params
      params.require(:library_item_reservation).permit(:item_id, :user_id, :received_at, :caution, :description)
    end
  end
end

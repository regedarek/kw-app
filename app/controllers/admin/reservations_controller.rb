module Admin
  class ReservationsController < Admin::BaseController
    def index
      reservations = Db::Reservation.order(:start_date)
      @reservations = if params[:state].try(:to_sym) == :archived
        reservations.archived
      else
        reservations.not_archived
      end
    end

    def create
      result = Admin::Reservations.new(reservation_params).create
      result.success { redirect_to admin_reservations_path, notice: 'Dodano' }
      result.invalid { |form:| redirect_to admin_reservations_path, alert: "Nie dodano: #{form.errors.messages}" }
      result.else_fail!
    end

    def edit
      @reservation = Db::Reservation.find(params[:id])
    end

    def update
      result = Admin::Reservations.new(reservation_params).update(params[:id])
      result.success { redirect_to edit_admin_reservation_path(params[:id]), notice: 'Zaktualizowano' }
      result.invalid { |form:| redirect_to edit_admin_reservation_path(params[:id]), alert: "Nie zaktualizowano bo: #{form.errors.messages}" }
      result.else_fail!
    end

    def archive
      reservation = Db::Reservation.find(params[:id])
      reservation.archive!

      redirect_to admin_reservations_path, notice: 'Zarchiwizowano rezerwację'
    end

    def give
      reservation = Db::Reservation.find(params[:id])
      reservation.give!

      redirect_to admin_reservations_path, notice: "Oznaczono jako w posiadaniu."
    end

    def charge
      reservation = Db::Reservation.find(params[:id])
      reservation.order.payment.update(cash: true)

      redirect_to edit_admin_reservation_path(reservation), notice: "Oznaczono jako zapłacone gotowką"
    end

    def remind
      reservation = Db::Reservation.find(params[:id])
      ReservationMailer.remind(reservation).deliver_later
      redirect_to admin_reservations_path, notice: 'Przypomniano i wyslano email'
    end

    def give_warning
      reservation = Db::Reservation.find(params[:id])
      reservation.user.increment(:warnings)
      reservation.user.save
      redirect_to edit_admin_reservation_path(reservation), alert: 'Dodano ostrzezenie'
    end

    def give_back_warning
      reservation = Db::Reservation.find(params[:id])
      reservation.user.decrement(:warnings)
      reservation.user.save
      redirect_to edit_admin_reservation_path(reservation), success: 'Usunieto ostrzezenie'
    end

    def destroy
      result = Admin::Reservations.destroy(params[:id])
      result.success { redirect_to admin_reservations_path, notice: 'Usunieto' }
      result.failure { redirect_to admin_reservations_path, alert: 'Nie usunieto' }
      result.else_fail!
    end

    private

    def reservation_params
      params.require(:admin_reservations_form).permit(:kw_id, :item_id, :start_date, :end_date, :description)
    end
  end
end

class PaymentsController < ApplicationController
  def charge
    payment = Db::ReservationPayment.find(params[:id])

    @dot_pay_form = Payments::DotPay::Form.new(payment: payment)

    redirect_to new_reservation_path
  end
end

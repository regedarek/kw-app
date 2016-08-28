class PaymentsController < ApplicationController
  def charge
    payment = Db::ReservationPayment.find(params[:id])

    Payments::ProcessPayment.new(payment: payment, type: :dotpay).call
  end
end

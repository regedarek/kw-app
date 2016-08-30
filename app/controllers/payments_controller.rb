class PaymentsController < ApplicationController
  def charge
    payment = Db::Payment.find(params[:id])
    result = Payments::CreatePayment.new(payment: payment).create
    result.success { |payment_url:| redirect_to payment_url }
  end
end

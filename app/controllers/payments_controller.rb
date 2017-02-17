require 'payments'

class PaymentsController < ApplicationController
  def index
  end

  def charge
    payment = Db::Payment.find(params[:id])
    result = Payments::CreatePayment.new(payment: payment).create
    result.success { |payment_url:| redirect_to payment_url }
    result.wrong_payment_url { |message:| redirect_to root_path, alert: message }
    result.dotpay_request_error { |message:| redirect_to root_path, alert: message }
  end
end

require 'payments'

class PaymentsController < ApplicationController
  def charge
    unless current_user.kw_id == 2345 || Rails.env.test?
      return redirect_to :back,
        alert: 'W tym momencie można płacić tylko gotówką przy odbiorze, skontaktuj się z opiekunem.'
    end

    payment = Db::Payment.find(params[:id])
    result = Payments::CreatePayment.new(payment: payment).create
    result.success { |payment_url:| redirect_to payment_url }
    result.wrong_payment_url { |message:| redirect_to root_path, alert: message }
    result.dotpay_request_error { |message:| redirect_to root_path, alert: message }
  end
end

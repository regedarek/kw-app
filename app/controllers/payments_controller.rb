class PaymentsController < ApplicationController
  def charge
    unless current_user.kw_id == 2345
      return redirect_to :back,
        alert: 'W tym momencie można płacić tylko gotówką przy odbiorze, skontaktuj się z opiekunem.'
    end

    payment = Db::Payment.find(params[:id])
    result = Payments::CreatePayment.new(payment: payment).create
    result.success { |payment_url:| redirect_to payment_url }
  end
end

class PaymentsController < ApplicationController
  def create
    result = Payments::InitializeDotPay.new(reservation_id: params[:reservation_id]).create
    result.success { }
    result.failure { }
  end
end

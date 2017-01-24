require 'payments'

module Api
  class PaymentsController < Api::BaseController
    def status
      notification = Payments::Dotpay::Notification.new(params)
      result = Payments::Dotpay::Status.new(notification: notification).process
      result.success { render text: 'OK' }
    end

    def thank_you
      if params[:status] == 'OK'
        redirect_to root_path, notice: 'Płatność została zrealizowana.'
      end
    end
  end
end

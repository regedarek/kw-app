module Api
  class PaymentsController < Api::BaseController
    def status
      notification = Payments::Dotpay::Notification.new(params)
      result = Payments::Dotpay::Status.new(notification: notification).process
      result.success { render text: 'OK' }
    end

    def thank_you
      if params[:status] == 'OK'
        redirect_to payments_path, notice: 'Twoja płatność została zrealizowana. Your payment proccess has been finished successfully.'
      end
    end
  end
end

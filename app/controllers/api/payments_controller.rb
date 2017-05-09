module Api
  class PaymentsController < Api::BaseController
    def status
      notification = Payments::Dotpay::Notification.new(params)
      result = Payments::Dotpay::Status.new(notification: notification).process
      result.success { render text: 'OK' }
      result.uncompleted { |status:| render text: status }
    end

    def thank_you
      if params[:status] == 'OK'
        redirect_to payments_path
      end
    end
  end
end

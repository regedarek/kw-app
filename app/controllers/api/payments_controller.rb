module Api
  class PaymentsController < Api::BaseController
    def status
      notification = Payments::Notification.new(params)
      status = Payments::Status.new(notification: notification).process
      render text: status
    end
  end
end

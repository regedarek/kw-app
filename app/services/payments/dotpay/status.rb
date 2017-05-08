module Payments
  module Dotpay
    class Status
      def initialize(notification:)
        @notification = notification
      end

      def process
        if @notification.completed?
          @notification.payment.charge!
          Success.new
        else
          Failure.new(:uncompleted, status: @notification.status)
        end
      end
    end
  end
end

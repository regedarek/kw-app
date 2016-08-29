module Payments
  module Dotpay
    class Status
      def initialize(notification:)
        @notification = notification
      end

      def process
        if @notification.completed?
          @notification.payment.charge!
          @notification.payment.reservation.reserve!
          Success.new
        end
      end
    end
  end
end

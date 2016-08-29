module Payments
  module Dotpay
    class Status
      def initialize(notification:)
        @notification = notification
      end

      def process
        if @notification.completed?
          Success.new
        end
      end
    end
  end
end

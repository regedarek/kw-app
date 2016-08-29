module Payments
  module Dotpay
    class Notification
      def initialize(params)
        @params = params
      end

      def completed?
        @params.fetch('operation_status') == 'completed'
      end
    end
  end
end

module Payments
  module Dotpay
    class Notification
      def initialize(params)
        @params = params
      end

      def completed?
        @params.fetch('operation_status') == 'completed'
      end

      def status
        @params.fetch('operation_status', 'unknown')
      end

      def payment
        Db::Payment.find_by(dotpay_id: @params.fetch(:control))
      end
    end
  end
end

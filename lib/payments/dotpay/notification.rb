module Payments
  module Dotpay
    class Notification
      def initialize(params)
        @params = params
      end

      def completed?
        @params.fetch('operation_status') == 'completed'
      end

      def payment
        Db::ReservationPayment.find_by(dotpay_id: @params.fetch(:control))
      end
    end
  end
end

module Training
  module Supplementary
    class Limiter
      def initialize(course)
        @course = course
      end

      def limit
        @course.limit
      end

      def prepaid_via_dotpay
        @course.sign_ups.includes(:payment).where(payments: { state: :prepaid })
      end

      def prepaid_via_cash
        @course.sign_ups.includes(:payment).where(payments: { cash: true })
      end

      def sum
        prepaid_via_dotpay&.count + prepaid_via_cash&.count
      end

      def reached?
        return false if limit == 0

        sum >= limit
      end
    end
  end
end

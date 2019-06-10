module Training
  module Supplementary
    class Limiter
      def initialize(course)
        @course = course
      end

      def sign_ups_started?
        @course.application_date.nil? || Time.current.in_time_zone >= @course.application_date.in_time_zone
      end

      def limit
        @course.limit
      end

      def open?
        @course.open || limit == 0
      end

      def all_prepaid
        @course.sign_ups.includes(:payment).where(payments: { state: :prepaid }).or(@course.sign_ups.includes(:payment).where(payments: { cash: true })).order(:created_at)
      end

      def all_unpaid
        @course.sign_ups.includes([:payment, :user]).where(payments: { state: :unpaid, cash: false }).order(:created_at)
      end

      def prepaid_via_dotpay
        @course.sign_ups.includes(:payment).where(payments: { state: :prepaid })
      end

      def prepaid_via_cash
        @course.sign_ups.includes(:payment).where(payments: { cash: true })
      end

      def sum
        prepaid_via_dotpay.merge(prepaid_via_cash)&.uniq&.count
      end

      def in_limit?(sign_up)
        return true if @course.open
        return true if limit == 0

        @course.sign_ups.first(limit).include?(sign_up)
      end

      def sign_ups_reached?
        return false if @course.open
        return false if limit == 0

        @course.sign_ups.count >= limit
      end

      def reached?
        return false if @course.open
        return false if limit == 0

        sum >= limit
      end
    end
  end
end

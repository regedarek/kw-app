module Membership
  class Activement
    attr_reader :user

    def initialize(user: nil)
      @user = user
    end

    def payment_year
      return Date.current.next_year.year if Date.current.between?(Date.new(Date.current.year, 11, 15), Date.current.end_of_year)

      return Date.current.year
    end

    def active?
      return false unless user
      return false unless user.membership_fees.any?
      return false unless user.membership_fees.where(year: prev_year..next_year).any?

      if current_year_fee
        if Date.current.between?(Date.new(Date.current.prev_year.year, 11, 15), Date.current.end_of_year)
          return true if current_year_fee.payment.paid? if current_year_fee.payment
        end
      end

      if prev_year_fee
        if Date.current.between?(Date.current.prev_year.beginning_of_year, Date.new(Date.current.year, 01, 15))
          return true if prev_year_fee.payment.paid? if prev_year_fee.payment
        end
      end

      if next_year_fee
        if Date.current.between?(Date.new(Date.current.year, 11, 15), Date.current.next_year.end_of_year)
          return true if next_year_fee.payment.paid? if next_year_fee.payment
        end
      end

      return false
    end

    private

    def prev_year_fee
      user.membership_fees.find_by(year: prev_year)
    end

    def current_year_fee
      user.membership_fees.find_by(year: current_year)
    end

    def next_year_fee
      user.membership_fees.find_by(year: next_year)
    end

    def current_year
      Date.current.year
    end

    def prev_year
      Date.current.prev_year.year
    end

    def next_year
      Date.current.next_year.year
    end
  end
end

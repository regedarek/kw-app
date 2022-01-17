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

    def profile_payment_year(profile)
      return profile.created_at.next_year.year if profile.created_at.between?(Date.new(profile.created_at.year, 11, 15), profile.created_at.end_of_year)

      return profile.created_at.year
    end

    def supplementary_training_active?
      return false unless user
      return true if profile_has_been_released?(user)
      return false unless user.membership_fees.any?
      return false unless user.membership_fees.where(year: prev_year..next_year).any?

      if current_year_fee
        if Date.current.between?(Date.current.beginning_of_year, Date.current.end_of_year)
          return true if current_year_fee.payment.paid? if current_year_fee.payment
        end
      end

      if next_year_fee
        if Date.current.between?(Date.new(Date.current.year, 11, 15), Date.current.next_year.end_of_year)
          return true if next_year_fee.payment.paid? if next_year_fee.payment
        end
      end

      return false
    end

    def active?
      return false unless user
      return true if profile_has_been_released?(user)
      return false unless user.membership_fees.any?
      return false unless user.membership_fees.where(year: prev_year..next_year).any?

      if current_year_fee
        if Date.current.between?(Date.new(Date.current.prev_year.year, 11, 15), Date.current.end_of_year)
          return true if current_year_fee.payment.paid? if current_year_fee.payment
        end
      end

      if prev_year_fee
        if Date.current.between?(Date.current.prev_year.beginning_of_year, Date.new(Date.current.year, 03, 31))
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

    def active_and_regular?
      active? && profile_is_regular?(user)
    end

    private

    def profile_is_regular?(user)
      if user.profile
        user.profile.position.any?{ |p| ['honorable_kw', 'senior', 'regular'].include?(p) }
      else
        false
      end
    end

    def profile_has_been_released?(user)
      if user.profile
        user.profile.position.any?{ |p| ['honorable_kw', 'senior', 'released'].include?(p) }
      else
        false
      end
    end

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

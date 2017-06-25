require 'results'

module UserManagement
  class ApplicationCost
    class << self
      def for(profile:)
        return Failure.new(:not_found) if profile.nil?
        year_fee = Date.today.month >= 9 ? 50 : 100
        return UserManagement::Cost.new(year_fee: 0, first_fee: 50) if profile.acomplished_courses.include?('basic_kw')
        return UserManagement::Cost.new(year_fee: year_fee, first_fee: 0) if profile.acomplished_courses.include?('instructors')
        return UserManagement::Cost.new(year_fee: year_fee, first_fee: 0) if profile.acomplished_courses.include?('other_club')

        UserManagement::Cost.new(year_fee: year_fee, first_fee: 50)
      end
    end
  end
end

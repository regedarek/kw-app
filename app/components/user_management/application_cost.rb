require 'results'

module UserManagement
  class ApplicationCost
    class << self
      def for(profile:)
        return Failure.new(:not_found) if profile.nil?

        return UserManagement::Cost.new(year_fee: 0, first_fee: 50, plastic: profile.plastic) if profile.acomplished_courses.include?('basic_kw')
        return UserManagement::Cost.new(year_fee: 0, first_fee: 50, plastic: profile.plastic) if profile.acomplished_courses.include?('cave_kw')
        return UserManagement::Cost.new(year_fee: year_fee(profile), first_fee: 0, plastic: profile.plastic) if profile.acomplished_courses.include?('instructors')
        return UserManagement::Cost.new(year_fee: year_fee(profile), first_fee: 0, plastic: profile.plastic) if profile.acomplished_courses.include?('other_club')

        UserManagement::Cost.new(year_fee: year_fee(profile), first_fee: 50, plastic: profile.plastic)
      end

      private

      def year_fee(profile)
        if profile && (profile.youth? || profile.retired?)
          Date.current.between?(Date.new(Date.current.year, 9, 1), Date.new(Date.current.year, 11, 15)) ? 50 : 100
        else
          Date.current.between?(Date.new(Date.current.year, 9, 1), Date.new(Date.current.year, 11, 15)) ? 75 : 150
        end
      end
    end
  end
end

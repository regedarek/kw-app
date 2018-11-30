module Training
  module Supplementary
    class SignUpRecord < ActiveRecord::Base
      self.table_name = 'supplementary_sign_ups'

      has_one :payment, as: :payable, dependent: :destroy, class_name: 'Db::Payment'
      belongs_to :package_type, class_name: 'Training::Supplementary::PackageTypeRecord', foreign_key: :supplementary_course_package_type_id
      belongs_to :user, class_name: 'Db::User', foreign_key: :user_id
      belongs_to :course, class_name: 'Training::Supplementary::CourseRecord', foreign_key: :course_id

      def cost
        if course.packages
          package_type.cost
        else
          course.price_kw
        end
      end

      def start_date
        if course
          course.start_date
        else
          Date.today
        end
      end

      def payment_type
        course.payment_type.to_sym
      end

      def description
        if user
          case payment_type
          when :trainings
            "Szkolenie: #{course.name} - Opłata od #{user.first_name} #{user.last_name} nr legitymacji klubowej #{user.kw_id}"
          when :club_trips
            "Organizacja wyjazdów klubowych: #{course.name} - Opłata od #{user.first_name} #{user.last_name} nr legitymacji klubowej #{user.kw_id}"
          else
            "Wydarzenie klubowe: #{course.name} - Opłata od #{user.first_name} #{user.last_name} nr legitymacji klubowej #{user.kw_id}"
          end
        else
          case payment_type
          when :trainings
            "Szkolenie: #{course.name} - Opłata od #{name}"
          when :club_trips
            "Organizacja wyjazdów klubowych: #{course.name} - Opłata od #{name}"
          else
            "Wydarzenie klubowe: #{course.name} - Opłata od #{name}"
          end
        end
      end
    end
  end
end

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

      def payment_type
        :trainings
      end

      def description
        if user
          if course.packages
            "Wydarzenie klubowe #{course.name}: Opłata od #{user.first_name} #{user.last_name} nr legitymacji klubowej #{user.kw_id}"
          else
            "Doszkalanie #{course.name}: Opłata od #{user.first_name} #{user.last_name} nr legitymacji klubowej #{user.kw_id}"
          end
        else
          "Doszkalanie #{course.name}: Opłata od #{name}"
        end
      end
    end
  end
end

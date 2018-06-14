module Training
  module Supplementary
    class SignUpRecord < ActiveRecord::Base
      self.table_name = 'supplementary_sign_ups'

      has_one :payment, as: :payable, dependent: :destroy, class_name: 'Db::Payment'
      belongs_to :user, class_name: 'Db::User', foreign_key: :user_id
      belongs_to :course, class_name: 'Training::Supplementary::CourseRecord', foreign_key: :course_id

      def cost
        course.price_kw
      end

      def description
        "Opłata od #{user.first_name} #{user.last_name} nr legitymacji klubowej: #{user.kw_id} na wydarzenie #{course.name}"
      end
    end
  end
end

module Training
  module Supplementary
    class SignUpRecord < ActiveRecord::Base
      self.table_name = 'supplementary_sign_ups'

      has_one :payment, as: :payable, dependent: :destroy, class_name: 'Db::Payment'
      belongs_to :user, class_name: 'Db::User', foreign_key: :user_id
      belongs_to :course, class_name: 'Training::Supplementary::CourseRecord', foreign_key: :course_id

      def description
        "Zaliczka od #{user.first_name} #{user.last_name} nr legitymacji klubowej: #{user.kw_id} na wydarzenie #{course.title}"
      end
    end
  end
end

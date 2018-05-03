module Training
  module Supplementary
    class SignUpRecord < ActiveRecord::Base
      self.table_name = 'supplementary_sign_ups'

      belongs_to :user, class_name: 'Db::User', foreign_key: :user_id
      belongs_to :course, class_name: 'Training::Supplementary::CourseRecord', foreign_key: :course_id
    end
  end
end

# == Schema Information
#
# Table name: supplementary_course_package_types
#
#  id                             :integer          not null, primary key
#  cost                           :integer          not null
#  increase_limit                 :boolean          default(FALSE), not null
#  membership                     :boolean          default(FALSE), not null
#  name                           :string           not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  supplementary_course_record_id :integer          not null
#
module Training
  module Supplementary
    class PackageTypeRecord < ActiveRecord::Base
      self.table_name = 'supplementary_course_package_types'

      belongs_to :course, class_name: 'Training::Supplementary::CourseRecord', foreign_key: 'supplementary_course_record_id'

      def name_with_cost
        if membership
          "[Członek KW] #{name} - #{cost} zł"
        else
          "[Poza KW] #{name} - #{cost} zł"
        end
      end
    end
  end
end

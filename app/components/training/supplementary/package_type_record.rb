module Training
  module Supplementary
    class PackageTypeRecord < ActiveRecord::Base
      self.table_name = 'supplementary_course_package_types'

      belongs_to :course, class_name: 'Training::Supplementary::CourseRecord', foreign_key: 'supplementary_course_record_id'
    end
  end
end

module Business
  class PackageTypeRecord < ActiveRecord::Base
    self.table_name = 'business_course_package_types'

    belongs_to :course, class_name: 'Business::CourseRecord', foreign_key: 'business_course_record_id'

    def name_with_cost
      if membership
        "[Członek KW] #{name} - #{cost} zł"
      else
        "[Poza KW] #{name} - #{cost} zł"
      end
    end
  end
end

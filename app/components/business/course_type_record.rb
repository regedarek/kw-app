module Business
  class CourseTypeRecord < ActiveRecord::Base
    self.table_name = 'business_course_types'

    has_many :courses, class_name: '::Business::CourseRecord', foreign_key: :course_type_id

    def logo_uri
      'kw.png'
    end
  end
end

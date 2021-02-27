module Business
  class ListCourseRecord < ActiveRecord::Base
    self.table_name = 'business_list_courses'

    belongs_to :course, class_name: '::Business::CourseRecord', foreign_key: :course_id
    belongs_to :list, class_name: '::Business::ListRecord', foreign_key: :list_id
  end
end

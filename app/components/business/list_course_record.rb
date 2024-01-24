# == Schema Information
#
# Table name: business_list_courses
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  course_id  :integer          not null
#  list_id    :integer          not null
#
# Indexes
#
#  index_business_list_courses_on_course_id_and_list_id  (course_id,list_id) UNIQUE
#
module Business
  class ListCourseRecord < ActiveRecord::Base
    self.table_name = 'business_list_courses'

    has_paper_trail

    belongs_to :course, class_name: '::Business::CourseRecord', foreign_key: :course_id
    belongs_to :list, class_name: '::Business::ListRecord', foreign_key: :list_id
  end
end

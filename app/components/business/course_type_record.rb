# == Schema Information
#
# Table name: business_course_types
#
#  id           :bigint           not null, primary key
#  logo_type    :integer          default(0), not null
#  name         :string           not null
#  sign_ups_uri :string           not null
#  type_sym     :string           not null
#
module Business
  class CourseTypeRecord < ActiveRecord::Base
    self.table_name = 'business_course_types'

    has_many :courses, class_name: '::Business::CourseRecord', foreign_key: :course_type_id

    def logo_uri
      'https://szkolaalpinizmu.pl/wp-content/uploads/2020/03/kw.png'
    end
  end
end

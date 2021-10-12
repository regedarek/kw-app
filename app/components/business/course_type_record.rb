module Business
  class CourseTypeRecord < ActiveRecord::Base
    self.table_name = 'business_course_types'

    has_many :courses, class_name: '::Business::CourseRecord', foreign_key: :course_type_id

    def logo_uri
      'https://panel.kw.krakow.pl/assets/kw-7b39344ecee6060042f85c3875d827e54a32ff867bf12eb62de751249dd20d0c.png'
    end
  end
end

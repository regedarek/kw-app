module Training
  module Supplementary
    class CourseRecord < ActiveRecord::Base
      self.table_name = 'supplementary_courses'
    end
  end
end

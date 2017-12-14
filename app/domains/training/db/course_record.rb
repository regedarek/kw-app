module Training
  module Db
    class CourseRecord < ActiveRecord::Base
      self.table_name = 'courses'

      validates :title, :cost, presence: true
    end
  end
end

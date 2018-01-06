module Training
  module Db
    class ParticipantRecord < ActiveRecord::Base
      RECOMMENDED_BY = %w(google facebook friends festival poster course)
      EQUIPMENT = %w(crampons pickaxe)
      self.table_name = 'participants'

      belongs_to :course, class_name: 'Training::Db::CourseRecord'
    end
  end
end

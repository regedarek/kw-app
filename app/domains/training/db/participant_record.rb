module Training
  module Db
    class ParticipantRecord < ActiveRecord::Base
      self.table_name = 'participants'

      belongs_to :course, class_name: 'Training::Db::CourseRecord'
    end
  end
end

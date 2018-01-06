module Training
  module Db
    class CourseRecord < ActiveRecord::Base
      self.table_name = 'courses'

      has_many :participants, class_name: 'Training::Db::ParticipantRecord', foreign_key: :course_id

      validates :title, :cost, presence: true
    end
  end
end

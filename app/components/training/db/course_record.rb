module Training
  module Db
    class CourseRecord < ActiveRecord::Base
      mount_uploader :baner, Training::Supplementary::BanerUploader
      self.table_name = 'courses'

      has_many :participants, class_name: 'Training::Db::ParticipantRecord', foreign_key: :course_id

      validates :title, :payment_type, :cost, presence: true
    end
  end
end

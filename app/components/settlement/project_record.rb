module Settlement
  class ProjectRecord < ActiveRecord::Base
    self.table_name = 'settlement_projects'

    belongs_to :user, class_name: 'Db::User'
    has_many :project_items, class_name: '::Settlement::ProjectItemRecord', foreign_key: :project_id
    has_many :business_courses, through: :project_items, source: :accountable, source_type: 'Business::CourseRecord'
  end
end

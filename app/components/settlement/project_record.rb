module Settlement
  class ProjectRecord < ActiveRecord::Base
    self.table_name = 'settlement_projects'

    belongs_to :user, class_name: 'Db::User'

    has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'

    has_many :project_items, class_name: 'Settlement::ProjectItemRecord', foreign_key: :project_id
    has_many :business_courses,
      through: :project_items,
      source: :accountable,
      source_type: 'Business::CourseRecord'

    has_many :contracts,
      through: :project_items,
      source: :accountable,
      source_type: 'Settlement::ContractRecord'
  end
end

module Settlement
  class ProjectRecord < ActiveRecord::Base
    include Workflow

    scope :opened, -> { where(state: 'open') }
    scope :closed, -> { where(state: 'closed') }

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

    workflow_column :state
    workflow do
      state :open do
        event :close, :transitions_to => :closed
      end
      state :closed
    end
  end
end

module Settlement
  class ProjectItemRecord < ActiveRecord::Base
    self.table_name = 'settlement_project_items'

    validates :accountable_type, uniqueness: { scope: :accountable_id }

    belongs_to :project, class_name: "Settlement::ProjectRecord", foreign_key: :project_id
    belongs_to :accountable, polymorphic: true
  end
end

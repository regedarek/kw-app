module Settlement
  class ProjectItemRecord < ActiveRecord::Base
    self.table_name = 'settlement_project_items'

    belongs_to :accountable, :polymorphic => true
    belongs_to :project, class_name: "::Settlement::ProjectRecord", foreign_key: :project_id
  end
end

module Settlement
  class ProjectItemRecord < ActiveRecord::Base
    self.table_name = 'settlement_project_items'

    belongs_to :accountable, :polymorphic => true
  end
end

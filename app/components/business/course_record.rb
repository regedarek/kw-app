module Business
  class CourseRecord < ActiveRecord::Base
    include Workflow
    extend FriendlyId

    friendly_id :name, use: :slugged
    self.table_name = 'business_courses'
    enum activity_type: [:ski, :climb, :cave]

    workflow_column :state
    workflow do
      state :draft do
        event :open, :transitions_to => :ready
      end
      state :ready
    end
  end
end

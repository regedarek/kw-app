module Settlement
  class ProjectRecord < ActiveRecord::Base
    include Workflow

    self.table_name = 'settlement_projects'

    scope :opened, -> { where(state: 'open') }
    scope :closed, -> { where(state: 'closed') }

    enum area_type: { other_budget: 0, course_budget: 1, section_budget: 2 }

    belongs_to :user, class_name: 'Db::User'

    has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'

    has_many :project_items,
      class_name: 'Settlement::ProjectItemRecord',
      foreign_key: :project_id

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

    def self.search_area_types_select
      area_types.map { |name, value| [I18n.t(name, scope: "activerecord.attributes.settlement/project_record.area_types"), value] }
    end

    def self.area_types_select
      area_types.map { |name, value| [I18n.t(name, scope: "activerecord.attributes.settlement/project_record.area_types"), name] }
    end
  end
end

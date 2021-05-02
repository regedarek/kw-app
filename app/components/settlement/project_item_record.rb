module Settlement
  class ProjectItemRecord < ActiveRecord::Base
    INCOME_ITEMS = ['Business::CourseRecord', 'Settlement::IncomeRecord', 'Training::Supplementary::CourseRecord'].freeze
    OUTCOME_ITEMS = ['Settlement::ContractRecord'].freeze

    self.table_name = 'settlement_project_items'

    scope :incomes, -> { includes(:accountable).where(accountable_type: INCOME_ITEMS) }
    scope :outcomes, -> { includes(:accountable).where(accountable_type: OUTCOME_ITEMS) }

    validates :project_id, uniqueness: { scope: :accountable_id }

    belongs_to :project, class_name: "Settlement::ProjectRecord", foreign_key: :project_id
    belongs_to :accountable, polymorphic: true

    def name
      return accountable.course_type.name if accountable_type == 'Business::CourseRecord'
      return accountable.name if accountable_type == 'Training::Supplementary::CourseRecord'
      return 'Bezpośrednia wpłata' if accountable_type == 'Settlement::IncomeRecord'
    end

    def income_cost
      cost || accountable.income_sum
    end

    def outcome_cost
      cost || accountable.cost
    end
  end
end

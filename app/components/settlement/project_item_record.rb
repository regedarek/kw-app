# == Schema Information
#
# Table name: settlement_project_items
#
#  id               :bigint           not null, primary key
#  accountable_type :string           not null
#  cost             :float
#  accountable_id   :integer          not null
#  project_id       :integer
#  user_id          :integer
#
# Indexes
#
#  index_settlement_project_items_on_accountable_id_and_project_id  (accountable_id,project_id) UNIQUE
#  index_settlement_project_items_on_user_id                        (user_id)
#
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
      if cost
        cost
      else
        if accountable
          accountable.income_sum
        else
          0
        end
      end
    end

    def outcome_cost
      if cost
        cost
      else
        if accountable
          accountable.cost
        else
          0
        end
      end
    end
  end
end

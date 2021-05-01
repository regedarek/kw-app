module Settlement
  class IncomeRecord < ActiveRecord::Base
    self.table_name = 'settlement_incomes'

    validates :cost, presence: true

    has_many :project_items, as: :accountable, class_name: '::Settlement::ProjectItemRecord', :dependent => :destroy
    has_many :projects, :through => :project_items, :dependent => :destroy

    def name_with_date
      "#{created_at.to_date} #{name}"
    end

    def income_sum
      cost
    end
  end
end

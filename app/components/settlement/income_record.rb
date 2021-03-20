module Settlement
  class IncomeRecord < ActiveRecord::Base
    self.table_name = 'settlement_incomes'

    has_many :project_items, as: :accountable, class_name: '::Settlement::ProjectItemRecord', :dependent => :destroy
    has_many :projects, :through => :project_items, :dependent => :destroy
  end
end

module Settlement
  class ContractTemplateRecord < ActiveRecord::Base
    self.table_name = 'contract_templates'

    has_many :contracts, class_name: 'Settlement::ContractRecord'
  end
end

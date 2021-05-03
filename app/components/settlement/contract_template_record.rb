module Settlement
  class ContractTemplateRecord < ActiveRecord::Base
    self.table_name = 'contract_templates'

    has_many :contracts, class_name: 'Settlement::ContractRecord'

    def self.for_select
      Settlement::ContractTemplateRecord.all.map { |template| [template.name, template.id] }
    end
  end
end

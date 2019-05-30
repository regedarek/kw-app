module Settlement
  class ContractorRecord < ActiveRecord::Base
    self.table_name = 'contractors'

    has_many :contracts, class_name: 'Settlement::ContractRecord', foreign_key: :contractor_id
  end
end

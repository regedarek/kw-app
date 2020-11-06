module Settlement
  class ContractorRecord < ActiveRecord::Base
    self.table_name = 'contractors'

    has_many :contracts, class_name: 'Settlement::ContractRecord', foreign_key: :contractor_id
    enum reason_type: [:both, :contracts, :sponsor]
  end
end

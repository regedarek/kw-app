module Training
  module Activities
    class ContractRecord < ActiveRecord::Base
      self.table_name = 'activities_contracts'

      has_many :route_contracts, class_name: 'Training::Activities::RouteContractsRecord', foreign_key: :contract_id
      has_many :routes, through: :route_contracts, dependent: :destroy
    end
  end
end

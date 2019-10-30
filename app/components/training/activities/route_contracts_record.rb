module Training
  module Activities
    class RouteContractsRecord < ActiveRecord::Base
      self.table_name = 'activities_route_contracts'

      belongs_to :contract, class_name: '::Training::Activities::ContractRecord'
      belongs_to :route, class_name: '::Db::Activities::MountainRoute'
    end
  end
end

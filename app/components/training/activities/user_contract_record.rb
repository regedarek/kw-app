module Training
  module Activities
    class UserContractRecord < ActiveRecord::Base
      self.table_name = 'training_user_contracts'

      belongs_to :contract, class_name: '::Training::Activities::ContractRecord'
      belongs_to :user, class_name: '::Db::User'
      belongs_to :route, class_name: 'Db::Activities::MountainRoute'

      validates :user_id, :contract_id, :route_id, presence: true
      validates :contract_id, uniqueness: { scope: [:route_id, :user_id] }
    end
  end
end

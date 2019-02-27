module Settlement
  class ContractUsersRecord < ActiveRecord::Base
    self.table_name = 'contract_users'

    belongs_to :user, class_name: 'Db::User', foreign_key: :user_id, inverse_of: :contract_users
    belongs_to :contract, class_name: 'Settlement::ContractRecord', foreign_key: :contract_id, inverse_of: :contract_users
  end
end

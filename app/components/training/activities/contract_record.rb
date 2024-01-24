# == Schema Information
#
# Table name: activities_contracts
#
#  id          :bigint           not null, primary key
#  description :text
#  name        :string           not null
#  score       :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
module Training
  module Activities
    class ContractRecord < ActiveRecord::Base
      self.table_name = 'activities_contracts'

      has_many :route_contracts, class_name: 'Training::Activities::RouteContractsRecord', foreign_key: :contract_id
      has_many :routes, through: :route_contracts, dependent: :destroy

      has_many :training_user_contracts, class_name: 'Training::Activities::UserContractRecord', foreign_key: :contract_id
      has_many :users, through: :training_user_contracts, class_name: 'Db::User'
    end
  end
end

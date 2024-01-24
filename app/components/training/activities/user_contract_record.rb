# == Schema Information
#
# Table name: training_user_contracts
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  contract_id :integer          not null
#  route_id    :integer          not null
#  user_id     :integer          not null
#
# Indexes
#
#  user_route_contract_unique  (user_id,route_id,contract_id) UNIQUE
#
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

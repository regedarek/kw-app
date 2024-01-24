# == Schema Information
#
# Table name: contract_users
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  contract_id :integer          not null
#  user_id     :integer          not null
#
module Settlement
  class ContractUsersRecord < ActiveRecord::Base
    self.table_name = 'contract_users'

    belongs_to :user, class_name: 'Db::User', foreign_key: :user_id, inverse_of: :contract_users
    belongs_to :contract, class_name: 'Settlement::ContractRecord', foreign_key: :contract_id, inverse_of: :contract_users
  end
end

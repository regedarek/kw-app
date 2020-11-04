module Management
  module Voting
    class CommissionRecord < ActiveRecord::Base
      self.table_name = 'management_commissions'

      validates :owner_id, uniqueness: true
      validates :owner_id, :authorized_id, :approval, presence: true
      validates :approval, acceptance: true

      belongs_to :owner, class_name: 'Db::User'
      belongs_to :authorized, class_name: 'Db::User'
    end
  end
end

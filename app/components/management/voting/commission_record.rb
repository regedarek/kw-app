# == Schema Information
#
# Table name: management_commissions
#
#  id            :bigint           not null, primary key
#  approval      :boolean          default(FALSE), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  authorized_id :integer          not null
#  owner_id      :integer          not null
#
# Indexes
#
#  index_management_commissions_on_owner_id  (owner_id) UNIQUE
#
module Management
  module Voting
    class CommissionRecord < ActiveRecord::Base
      self.table_name = 'management_commissions'

      validates :owner_id, uniqueness: true
      validates :owner_id, :authorized_id, :approval, presence: true
      validates :approval, acceptance: true
      validate :not_myself

      belongs_to :owner, class_name: 'Db::User'
      belongs_to :authorized, class_name: 'Db::User'

      def not_myself
        if owner_id == authorized_id
          return errors.add(:authorized_id, 'nie może być takie samo jak właściciel pełnomocnictwa')
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: membership_fees
#
#  id         :integer          not null, primary key
#  cost       :integer          default(100), not null
#  plastic    :boolean          default(FALSE), not null
#  year       :string
#  created_at :datetime
#  updated_at :datetime
#  creator_id :integer
#  kw_id      :integer
#
# Indexes
#
#  index_membership_fees_on_kw_id  (kw_id)
#
module Db
  module Membership
    class Fee < ActiveRecord::Base
      self.table_name = 'membership_fees'
      has_one :payment, as: :payable, dependent: :destroy
      belongs_to :user, foreign_key: :kw_id, primary_key: :kw_id, optional: true
      belongs_to :profile, foreign_key: :kw_id, primary_key: :kw_id, optional: true

      validates :kw_id, uniqueness: { scope: :year }

      def payment_type
        :fees
      end

      def description
        if cost == 200
          "Składka członkowska za rok #{year} oraz opłata reaktywacyjna od #{user.first_name} #{user.last_name} nr legitymacji klubowej: #{kw_id}"
        else
          "Składka członkowska za rok #{year} od #{user.first_name} #{user.last_name} nr legitymacji klubowej: #{kw_id}"
        end
      end
    end
  end
end

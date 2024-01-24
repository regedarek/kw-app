# == Schema Information
#
# Table name: payments
#
#  id           :integer          not null, primary key
#  cash         :boolean          default(FALSE)
#  dotpay_id    :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  state        :string           default("unpaid")
#  payable_type :string
#  payable_id   :integer
#  payment_url  :string
#  cash_user_id :integer
#  deleted      :boolean          default(FALSE), not null
#  refunded_at  :datetime
#  amount       :integer
#
module Db
  class Payment < ActiveRecord::Base
    include Workflow
    has_paper_trail

    belongs_to :payable, polymorphic: true

    workflow_column :state
    workflow do
      state :unpaid do
        event :charge, :transitions_to => :prepaid
      end
      state :prepaid
    end

    def paid?
      prepaid? || cash?
    end
  end
end

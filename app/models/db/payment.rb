# == Schema Information
#
# Table name: payments
#
#  id           :integer          not null, primary key
#  amount       :integer
#  cash         :boolean          default(FALSE)
#  deleted      :boolean          default(FALSE), not null
#  payable_type :string
#  payment_url  :string
#  refunded_at  :datetime
#  state        :string           default("unpaid")
#  created_at   :datetime
#  updated_at   :datetime
#  cash_user_id :integer
#  dotpay_id    :string
#  payable_id   :integer
#
module Db
  class Payment < ActiveRecord::Base
    include Workflow
    has_paper_trail

    belongs_to :payable, polymorphic: true, optional: true

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

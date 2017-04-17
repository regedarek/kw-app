module Db
  class Payment < ActiveRecord::Base
    include Workflow
    belongs_to :payable, polymorphic: true

    workflow_column :state
    workflow do
      state :unpaid do
        event :charge, :transitions_to => :prepaid
      end
      state :prepaid
    end

    def description
      "Opłata za zamówienie ##{order.id}"
    end
  end
end

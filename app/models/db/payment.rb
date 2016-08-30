module Db
  class Payment < ActiveRecord::Base
    include Workflow
    belongs_to :order

    workflow_column :state
    workflow do
      state :unpaid do
        event :charge, :transitions_to => :prepaid
      end
      state :prepaid
    end

    def description
      "Oplata za zamownienie ##{order.id}"
    end
  end
end

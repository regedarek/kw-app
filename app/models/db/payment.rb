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

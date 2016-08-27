class Db::ReservationPayment < ActiveRecord::Base
  include Workflow
  belongs_to :reservation

  workflow_column :state
  workflow do
    state :unpaid do
      event :charge, :transitions_to => :prepaid
    end
    state :prepaid
  end
end

module Db
  module Payments
    class ReservationFee < Db::Payment
      include Workflow
      belongs_to :reservation, foreign_key: :resource_id

      workflow_column :state
      workflow do
        state :unpaid do
          event :charge, :transitions_to => :prepaid
        end
        state :prepaid
      end

      def description
        "Oplata za rezerwacje: ##{reservation.id}"
      end
    end
  end
end

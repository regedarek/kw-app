module Db
  module Payments
    class MembershipFee < Db::Payment
      belongs_to :yearly_fee

      def description
        "Skladka czlonkowska za rok: ##{yearly_fee.year}"
      end
    end
  end
end

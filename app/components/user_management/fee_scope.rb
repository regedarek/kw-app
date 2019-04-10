module UserManagement
  class FeeScope
    class << self
      def for(year: Date.today.year)
        Db::Membership::Fee
          .includes(:payment)
          .where(year: year, payments: { state: :prepaid }).count
      end
    end
  end
end

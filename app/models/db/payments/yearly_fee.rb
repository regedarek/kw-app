module Db
  module Payments
    class YearlyFee < ActiveRecord::Base
      belongs_to :user
      belongs_to :payment
    end
  end
end

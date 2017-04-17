module Db
  class MembershipFee < ActiveRecord::Base
    has_one :payment, as: :payable

    belongs_to :user, foreign_key: :kw_id, primary_key: :kw_id
  end
end

module Db
  class MembershipFee < ActiveRecord::Base
    has_one :service, as: :serviceable
    has_one :order, through: :service

    belongs_to :user, foreign_key: :kw_id, primary_key: :kw_id
  end
end

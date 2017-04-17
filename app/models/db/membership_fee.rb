module Db
  class MembershipFee < ActiveRecord::Base
    has_one :payment, as: :payable, dependent: :destroy
    belongs_to :user, foreign_key: :kw_id, primary_key: :kw_id

    def description
      if cost == 150
        "Składka członkowska za rok #{services.first.serviceable.year} oraz opłata reaktywacyjna od #{services.first.serviceable.user.first_name} #{services.first.serviceable.user.last_name} nr legitymacji klubowej: #{services.first.serviceable.user.kw_id}"
      else
        "Składka członkowska za rok #{services.first.serviceable.year} od #{services.first.serviceable.user.first_name} #{services.first.serviceable.user.last_name} nr legitymacji klubowej: #{services.first.serviceable.user.kw_id}"
      end
    end
  end
end

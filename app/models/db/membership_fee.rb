module Db
  class MembershipFee < ActiveRecord::Base
    has_one :payment, as: :payable, dependent: :destroy
    belongs_to :user, foreign_key: :kw_id, primary_key: :kw_id

    def description
      if cost == 150
        "Składka członkowska za rok #{year} oraz opłata reaktywacyjna od #{user.first_name} #{user.last_name} nr legitymacji klubowej: #{kw_id}"
      else
        "Składka członkowska za rok #{year} od #{user.first_name} #{user.last_name} nr legitymacji klubowej: #{kw_id}"
      end
    end
  end
end

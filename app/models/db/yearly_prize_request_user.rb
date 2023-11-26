class Db::YearlyPrizeRequestUser < ApplicationRecord
  belongs_to :yearly_prize_request
  belongs_to :user
end

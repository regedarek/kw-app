# == Schema Information
#
# Table name: yearly_prize_request_users
#
#  id                      :bigint           not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  user_id                 :bigint           not null
#  yearly_prize_request_id :bigint           not null
#
# Indexes
#
#  index_yearly_prize_request_users_on_user_id                  (user_id)
#  index_yearly_prize_request_users_on_yearly_prize_request_id  (yearly_prize_request_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (yearly_prize_request_id => yearly_prize_requests.id)
#
class Db::YearlyPrizeRequestUser < ApplicationRecord
  belongs_to :yearly_prize_request
  belongs_to :user
end

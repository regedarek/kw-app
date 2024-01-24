# == Schema Information
#
# Table name: hearts
#
#  id                :integer          not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  mountain_route_id :integer
#  user_id           :integer
#
# Indexes
#
#  index_hearts_on_mountain_route_id  (mountain_route_id)
#  index_hearts_on_user_id            (user_id)
#
module Db
  class Heart < ActiveRecord::Base
    belongs_to :mountain_route, counter_cache: true, class_name: 'Db::Activities::MountainRoute', foreign_key: :mountain_route_id
    belongs_to :user, class_name: 'Db::User'

    validates :user_id, uniqueness: { scope: :mountain_route_id }
  end
end

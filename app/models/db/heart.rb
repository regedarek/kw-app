module Db
  class Heart < ActiveRecord::Base
    belongs_to :fav_mountain_route, class_name: 'Db::Activities::MountainRoute'
    belongs_to :user, class_name: 'Db::User'

    validates :user_id, uniqueness: { scope: :mountain_route_id }
  end
end

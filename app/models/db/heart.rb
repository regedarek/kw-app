module Db
  class Heart < ActiveRecord::Base
    belongs_to :mountain_route, counter_cache: true, class_name: 'Db::Activities::MountainRoute', foreign_key: :mountain_route_id
    belongs_to :user, class_name: 'Db::User'

    validates :user_id, uniqueness: { scope: :mountain_route_id }
  end
end

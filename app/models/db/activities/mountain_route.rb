module Db
  module Activities
    class MountainRoute < ActiveRecord::Base
      enum route_type: [:ski, :regular_climbing, :winter_climbing]

      belongs_to :user

      validates :name, :rating, :partners, :climbing_date, presence: true
    end
  end
end

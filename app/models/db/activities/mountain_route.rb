module Db
  module Activities
    class MountainRoute < ActiveRecord::Base
      enum route_type: [:ski, :regular_climbing, :winter_climbing]

      validates :name, :rating, :partners, :climbing_date, presence: true

      belongs_to :user
    end
  end
end

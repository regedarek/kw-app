module Db
  module Activities
    class MountainRoute < ActiveRecord::Base
      belongs_to :peak
      belongs_to :user
      enum route_type: [:ski, :regular_climbing, :winter_climbing]

      validates :peak_id, :name, :partners, :climbing_date,
        presence: true
    end
  end
end

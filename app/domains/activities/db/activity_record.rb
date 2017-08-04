module Db
  class ActivityRecord < ActiveRecord::Base
    enum route_type: [:ski, :regular_climbing, :winter_climbing]

    belongs_to :user
  end
end

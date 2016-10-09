module Db
  class Route < ActiveRecord::Base
    belongs_to :peak
    enum route_type: [:ski, :regular_climbing, :winter_climbing]

    validates :peak_id, :name, :partners, :climbing_date,
      presence: true
  end
end

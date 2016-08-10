module Db
  class Route < ActiveRecord::Base
    belongs_to :peak

    validates :peak_id, :name, :partners, :climbing_date,
      presence: true
  end
end

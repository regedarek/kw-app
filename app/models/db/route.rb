module Db
  class Route < ActiveRecord::Base
    belongs_to :peak
    enum route_type: [:narty, :wspin_lato, :wspin_zima]

    validates :peak_id, :name, :partners, :climbing_date,
      presence: true
  end
end

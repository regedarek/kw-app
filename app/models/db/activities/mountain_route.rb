module Db
  module Activities
    class MountainRoute < ActiveRecord::Base
      enum route_type: [:ski, :regular_climbing, :winter_climbing]

      validates :name, :rating, :partners, :climbing_date, presence: true

      belongs_to :user

      def self.text_search(query)
        if query.present?
          where("name ilike :q or partners ilike :q or mountains ilike :q or description ilike :q or peak ilike :q or area ilike :q", q: "%#{query}%")
        else
          where(nil)
        end
      end
    end
  end
end

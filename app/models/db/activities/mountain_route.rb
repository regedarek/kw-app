module Db
  module Activities
    class MountainRoute < ActiveRecord::Base
      enum route_type: [:ski, :regular_climbing, :winter_climbing]

      validates :name, :rating, :partners, :climbing_date, presence: true

      belongs_to :user

      def self.text_search(query, route_type:)
        if query.present?
          if route_type.present?
            where("route_type is #{route_type} name ilike :q or partners ilike :q or mountains ilike :q or description ilike :q or peak ilike :q or area ilike :q", q: "%#{query}%")
          else
            where("name ilike :q or partners ilike :q or mountains ilike :q or description ilike :q or peak ilike :q or area ilike :q", q: "%#{query}%")
          end
        else
          if route_type.present?
            where(route_type: route_type)
          else
            where(nil)
          end
        end
      end
    end
  end
end

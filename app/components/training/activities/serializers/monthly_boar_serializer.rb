module Training
  module Activities
    module Serializers
      class MonthlyBoarSerializer < ActiveModel::Serializer
        attributes :id, :kw_id, :avatar, :total_mountain_routes_length
      end
    end
  end
end

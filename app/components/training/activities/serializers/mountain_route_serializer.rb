module Training
  module Activities
    module Serializers
      class MountainRouteSerializer < ActiveModel::Serializer
        attributes :id, :name, :persons, :route_type, :climbing_date, :training, :slug, :attachments, :hearts_count, :colleagues_avatars, :partners, :partners?
      end
    end
  end
end


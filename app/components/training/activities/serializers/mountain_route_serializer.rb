module Training
  module Activities
    module Serializers
      class MountainRouteSerializer < ActiveModel::Serializer
        attributes :id, :name, :persons, :route_type,
          :climbing_date, :training, :slug, :attachments,
          :hearts_count, :partners

        belongs_to :user, serializer: UserManagement::UserSerializer
        has_many :colleagues, serializer: UserManagement::UserSerializer
        has_many :users, serializer: UserManagement::UserSerializer
      end
    end
  end
end


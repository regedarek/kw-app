module Shop
  class ItemSerializer < ActiveModel::Serializer
    attributes :id, :name, :description

    has_many :photos
  end
end

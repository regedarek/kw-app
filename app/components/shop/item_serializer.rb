module Shop
  class ItemSerializer < ActiveModel::Serializer
    attributes :id, :name, :description, :state, :created_at, :updated_at

    has_many :photos
    has_many :item_kinds
  end
end

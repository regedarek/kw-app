module Shop
  class OrderSerializer < ActiveModel::Serializer
    attributes :id

    belongs_to :user
    has_many :items
  end
end

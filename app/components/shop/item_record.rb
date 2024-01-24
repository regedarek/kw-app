# == Schema Information
#
# Table name: shop_items
#
#  id          :bigint           not null, primary key
#  description :text
#  name        :string
#  slug        :string           not null
#  state       :string           default("draft"), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
module Shop
  class ItemRecord < ActiveRecord::Base
    extend FriendlyId
    self.table_name = 'shop_items'
    friendly_id :slug_candidates, use: :slugged

    scope :published, -> { where(state: 'published') }

    has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'
    has_many :photos, as: :uploadable, class_name: 'Storage::UploadRecord'

    has_many :item_kinds, class_name: '::Shop::ItemKindRecord', foreign_key: :item_id, dependent: :destroy

    has_many :order_items, class_name: '::Shop::OrderItemRecord', foreign_key: :item_id
    has_many :orders, through: :order_items, dependent: :destroy, foreign_key: :order_id

    accepts_nested_attributes_for :item_kinds, allow_destroy: true

    def primary_photo
      photos.first
    end

    def price
      item_kinds.first.price
    end

    def slug_candidates
      [
        [:name]
      ]
    end
  end
end

module Shop
  class ItemRecord < ActiveRecord::Base
    extend FriendlyId
    include Workflow
    self.table_name = 'shop_items'
    friendly_id :slug_candidates, use: :slugged

    has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'
    has_many :photos, as: :uploadable, class_name: 'Storage::UploadRecord'

    has_many :item_kinds, class_name: '::Shop::ItemKindRecord', foreign_key: :item_id, dependent: :destroy

    has_many :order_items, class_name: '::Shop::OrderItemRecord', foreign_key: :item_id
    has_many :orders, through: :order_items, dependent: :destroy, foreign_key: :order_id

    accepts_nested_attributes_for :item_kinds, allow_destroy: true

    def slug_candidates
      [
        [:name]
      ]
    end

    workflow_column :state
    workflow do
      state :draft do
        event :publish, transitions_to: :published
      end
      state :published
    end
  end
end

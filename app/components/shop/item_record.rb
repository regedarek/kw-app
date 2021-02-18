module Shop
  class ItemRecord < ActiveRecord::Base
    self.table_name = 'shop_items'

    has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'
  end
end

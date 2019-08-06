module Library
  class ItemTagsRecord < ActiveRecord::Base
    self.table_name = 'library_item_tags'

    belongs_to :item, class_name: 'Library::ItemRecord', foreign_key: :item_id, inverse_of: :item_tags
    belongs_to :tag, class_name: 'Library::TagRecord', foreign_key: :tag_id, inverse_of: :item_tags
  end
end

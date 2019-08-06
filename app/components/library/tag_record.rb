module Library
  class TagRecord < ActiveRecord::Base
    self.table_name = 'library_tags'

    has_many :item_tags, class_name: '::Library::ItemTagsRecord', foreign_key: :tag_id
    has_many :items, class_name: '::Library::ItemRecord', through: :item_tags, foreign_key: :item_id, dependent: :destroy
  end
end

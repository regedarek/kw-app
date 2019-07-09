module Library
  class ItemAuthorsRecord < ActiveRecord::Base
    self.table_name = 'library_item_authors'

    belongs_to :item, class_name: 'Library::ItemRecord', foreign_key: :item_id, inverse_of: :item_authors
    belongs_to :author, class_name: 'Library::AuthorRecord', foreign_key: :author_id, inverse_of: :item_authors
  end
end

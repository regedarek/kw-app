module Library
  class AuthorRecord < ActiveRecord::Base
    self.table_name = 'library_authors'

    has_many :item_authors, class_name: 'Library::ItemAuthorsRecord', foreign_key: :author_id
    has_many :items, class_name: 'Library::ItemRecord', through: :item_authors, foreign_key: :item_id, dependent: :destroy
  end
end

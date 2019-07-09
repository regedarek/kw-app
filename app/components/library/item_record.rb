module Library
  class ItemRecord < ActiveRecord::Base
    self.table_name = 'library_items'

    enum doc_type: [:book, :magazine]

    has_many :item_authors, class_name: '::Library::ItemAuthorsRecord', foreign_key: :item_id
    has_many :authors, class_name: '::Library::AuthorRecord', through: :item_authors, foreign_key: :author_id, dependent: :destroy

    def authors_names=(ids)
      self.author_ids = ids
    end
    attr_reader :authors_names
  end
end

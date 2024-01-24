# == Schema Information
#
# Table name: library_item_authors
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  author_id  :integer
#  item_id    :integer
#
# Indexes
#
#  index_library_item_authors_on_item_id_and_author_id  (item_id,author_id) UNIQUE
#
module Library
  class ItemAuthorsRecord < ActiveRecord::Base
    self.table_name = 'library_item_authors'

    belongs_to :item, class_name: 'Library::ItemRecord', foreign_key: :item_id, inverse_of: :item_authors
    belongs_to :author, class_name: 'Library::AuthorRecord', foreign_key: :author_id, inverse_of: :item_authors
  end
end

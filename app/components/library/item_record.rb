module Library
  class ItemRecord < ActiveRecord::Base
    self.table_name = 'library_items'

    enum doc_type: [:book, :magazine]
  end
end

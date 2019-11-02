class RenameAuthorUrlToAuthorId < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :author_url
    add_column :users, :author_number, :integer
  end
end

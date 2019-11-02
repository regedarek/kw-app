class AddAuthorUrlToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :author_url, :string
  end
end

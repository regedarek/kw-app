class AddSnwBlogToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :snw_blog, :boolean, null: false, default: false
  end
end

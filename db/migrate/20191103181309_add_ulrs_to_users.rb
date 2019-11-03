class AddUlrsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :facebook_url, :string
    add_column :users, :instagram_url, :string
    add_column :users, :website_url, :string
  end
end

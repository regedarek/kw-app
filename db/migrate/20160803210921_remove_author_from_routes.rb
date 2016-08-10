class RemoveAuthorFromRoutes < ActiveRecord::Migration
  def change
    remove_column :routes, :author, :string
  end
end

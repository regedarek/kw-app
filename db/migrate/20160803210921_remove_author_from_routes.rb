class RemoveAuthorFromRoutes < ActiveRecord::Migration[5.0]
  def change
    remove_column :routes, :author, :string
  end
end

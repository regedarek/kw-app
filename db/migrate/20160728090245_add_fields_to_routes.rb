class AddFieldsToRoutes < ActiveRecord::Migration[5.0]
  def change
    add_column :routes, :rating, :integer
    add_column :routes, :author, :string
    add_column :routes, :climbing_date, :date
  end
end

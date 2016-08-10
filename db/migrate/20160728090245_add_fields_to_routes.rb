class AddFieldsToRoutes < ActiveRecord::Migration
  def change
    add_column :routes, :rating, :integer
    add_column :routes, :author, :string
    add_column :routes, :climbing_date, :date
  end
end

class DropCourses < ActiveRecord::Migration[5.0]
  def change
    drop_table :courses
    drop_table :auctions
    drop_table :auction_products
    drop_table :mas_sign_ups
    drop_table :peaks
    drop_table :valleys
  end
end

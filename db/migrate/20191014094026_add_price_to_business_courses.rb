class AddPriceToBusinessCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :business_courses, :price, :integer
  end
end

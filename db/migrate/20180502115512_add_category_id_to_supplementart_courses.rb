class AddCategoryIdToSupplementartCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :supplementary_courses, :category, :integer, null: false, default: 0
  end
end

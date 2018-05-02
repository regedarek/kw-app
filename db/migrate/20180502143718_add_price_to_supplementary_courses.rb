class AddPriceToSupplementaryCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :supplementary_courses, :price, :boolean, default: false, null: false
  end
end

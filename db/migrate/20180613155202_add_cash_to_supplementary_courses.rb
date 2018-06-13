class AddCashToSupplementaryCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :supplementary_courses, :cash, :boolean, null: false, default: false
  end
end

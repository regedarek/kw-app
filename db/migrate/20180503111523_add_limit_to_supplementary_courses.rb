class AddLimitToSupplementaryCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :supplementary_courses, :limit, :integer, null: false, default: 0
    add_column :supplementary_courses, :one_day, :boolean, null: false, default: true
    add_column :supplementary_courses, :active, :boolean, null: false, default: false
  end
end

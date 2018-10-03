class AddSlugIndexToCourses < ActiveRecord::Migration[5.0]
  def change
    change_column :supplementary_courses, :slug, :string, null: false
    add_index :supplementary_courses, :slug, unique: true
  end
end

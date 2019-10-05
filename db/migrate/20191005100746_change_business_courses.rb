class ChangeBusinessCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :business_courses, :slug, :string, null: false
    add_index :business_courses, :slug, unique: true
    add_column :business_courses, :state, :string, default: 'draft', null: false
  end
end

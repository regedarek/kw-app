class AddStateToSupplementaryCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :supplementary_courses, :state, :integer, null: false, default: 0
  end
end

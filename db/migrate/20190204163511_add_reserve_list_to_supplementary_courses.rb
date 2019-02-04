class AddReserveListToSupplementaryCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :supplementary_courses, :reserve_list, :boolean, default: false, null: false
  end
end

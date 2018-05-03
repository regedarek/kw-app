class AddFeesToSupplementaryCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :supplementary_courses, :last_fee_paid, :boolean, default: false, null: false
  end
end

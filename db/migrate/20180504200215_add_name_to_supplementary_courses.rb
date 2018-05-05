class AddNameToSupplementaryCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :supplementary_sign_ups, :name, :string
  end
end

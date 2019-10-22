class AddSendManuallyToSupplementaryCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :supplementary_courses, :send_manually, :boolean, null: false, default: false
  end
end

class AddGroupTypeToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :group_type, :integer, default: 0, null: false
  end
end

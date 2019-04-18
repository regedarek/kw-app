class AddStateToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :state, :string, default: 'draft'
  end
end

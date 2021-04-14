class AddStateToManagementResolutions < ActiveRecord::Migration[5.2]
  def change
    add_column :management_resolutions, :state, :string, null: false, default: 'draft'
  end
end

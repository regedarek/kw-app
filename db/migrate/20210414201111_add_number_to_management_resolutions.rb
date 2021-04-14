class AddNumberToManagementResolutions < ActiveRecord::Migration[5.2]
  def change
    add_column :management_resolutions, :number, :string, null: false
  end
end

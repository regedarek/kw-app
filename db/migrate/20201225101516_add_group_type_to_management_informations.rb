class AddGroupTypeToManagementInformations < ActiveRecord::Migration[5.2]
  def change
    add_column :management_informations, :group_type, :integer, default: 0, null: false
  end
end

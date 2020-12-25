class AddStarredToManagementInformations < ActiveRecord::Migration[5.2]
  def change
    add_column :management_informations, :starred, :boolean, default: false, null: false
  end
end

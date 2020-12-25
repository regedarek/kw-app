class AddWebToManagementInformations < ActiveRecord::Migration[5.2]
  def change
    add_column :management_informations, :web, :boolean, default: false, null: false
  end
end

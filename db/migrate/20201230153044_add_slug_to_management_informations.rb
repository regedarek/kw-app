class AddSlugToManagementInformations < ActiveRecord::Migration[5.2]
  def change
    add_column :management_informations, :slug, :string
  end
end

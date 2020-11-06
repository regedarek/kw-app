class AddContactNameToContractors < ActiveRecord::Migration[5.2]
  def change
    add_column :contractors, :contact_name, :string
  end
end

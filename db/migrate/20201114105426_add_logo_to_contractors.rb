class AddLogoToContractors < ActiveRecord::Migration[5.2]
  def change
    add_column :contractors, :logo, :string
  end
end

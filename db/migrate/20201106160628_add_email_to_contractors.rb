class AddEmailToContractors < ActiveRecord::Migration[5.2]
  def change
    add_column :contractors, :email, :string
    add_column :contractors, :www, :string
  end
end

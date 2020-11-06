class AddPhoneToContractors < ActiveRecord::Migration[5.2]
  def change
    add_column :contractors, :phone, :string
  end
end

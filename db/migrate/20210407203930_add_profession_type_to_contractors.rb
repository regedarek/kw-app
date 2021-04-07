class AddProfessionTypeToContractors < ActiveRecord::Migration[5.2]
  def change
    add_column :contractors, :profession_type, :integer, null: false, default: 0
  end
end

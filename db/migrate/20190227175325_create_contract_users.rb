class CreateContractUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :contract_users do |t|
      t.integer :contract_id, null: false
      t.integer :user_id, null: false
      t.timestamps
    end
  end
end

class CreateTrainingUserContracts < ActiveRecord::Migration[5.2]
  def change
    create_table :training_user_contracts do |t|
      t.integer :user_id, null: false
      t.integer :route_id, null: false
      t.integer :contract_id, null: false
      t.timestamps
    end

    add_index :training_user_contracts, [:user_id, :route_id, :contract_id], unique: true, name: 'user_route_contract_unique'
  end
end

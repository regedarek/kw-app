class CreateTrainingUserContracts < ActiveRecord::Migration[5.2]
  def change
    create_table :training_user_contracts do |t|
      t.integer :user_id, null: false
      t.integer :route_id, null: false
      t.integer :contract_id, null: false
      t.timestamps
    end
  end
end

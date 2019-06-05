class CreateContractEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :contract_events do |t|
      t.integer :event_id, null: false
      t.integer :contract_id, null: false
      t.timestamps
    end
  end
end

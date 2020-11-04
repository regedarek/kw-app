class CreateManagementCommissions < ActiveRecord::Migration[5.2]
  def change
    create_table :management_commissions do |t|
      t.integer :owner_id, null: false
      t.integer :authorized_id, null: false
      t.boolean :approval, null: false, default: false
      t.timestamps
    end

    add_index :management_commissions, :owner_id, unique: true
  end
end

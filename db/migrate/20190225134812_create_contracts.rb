class CreateContracts < ActiveRecord::Migration[5.2]
  def change
    create_table :contracts do |t|
      t.string :title
      t.string :state, null: false, default: 'new'
      t.integer :creator_id, null: false
      t.text :description
      t.float :cost
      t.integer :acceptor_id
      t.timestamps
    end
  end
end

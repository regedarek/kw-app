class BusinessLists < ActiveRecord::Migration[5.2]
  def change
    create_table :business_lists do |t|
      t.text :description
      t.integer :sign_up_id, unique: true, null: false
      t.timestamps
    end
  end
end

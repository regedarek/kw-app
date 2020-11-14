class CreateDiscounts < ActiveRecord::Migration[5.2]
  def change
    create_table :marketing_discounts do |t|
      t.string :logo
      t.integer :contractor_id, null: false
      t.integer :user_id
      t.string :description
      t.string :attachments
      t.integer :amount
      t.integer :amount_type
      t.string :link

      t.timestamps
    end
  end
end

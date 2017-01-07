class CreateAuctionProduct < ActiveRecord::Migration[5.0]
  def change
    create_table :auction_products do |t|
      t.string :name
      t.integer :auction_id
      t.integer :price
      t.text :description
      t.boolean :sold
      t.timestamps
    end
  end
end

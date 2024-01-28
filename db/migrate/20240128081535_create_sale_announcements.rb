class CreateSaleAnnouncements < ActiveRecord::Migration[5.2]
  def change
    create_table :sale_announcements do |t|
      t.string :name, null: false
      t.references :user, foreign_key: true
      t.text :description
      t.float :price
    end
  end
end

class CreateRoutesTable < ActiveRecord::Migration[5.0]
  def change
    create_table :routes do |t|
      t.integer :user_id
      t.string :name
      t.text :description
      t.integer :difficulty
      t.string :partners
    end
  end
end

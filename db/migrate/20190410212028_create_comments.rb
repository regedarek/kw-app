class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.string :commentable_type, null: false
      t.integer :commentable_id, null: false
      t.integer :user_id, null: false
      t.text :body
      t.timestamps
    end
  end
end

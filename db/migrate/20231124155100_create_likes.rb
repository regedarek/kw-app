class CreateLikes < ActiveRecord::Migration[5.2]
  def change
    create_table :likes do |t|
      t.references :user, foreign_key: true, null: false
      t.references :likeable, polymorphic: true, null: false

      t.timestamps
      t.index [:user_id, :likeable_type, :likeable_id ], unique: true
    end
  end
end

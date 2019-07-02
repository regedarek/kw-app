class CreateProfileLists < ActiveRecord::Migration[5.2]
  def change
    create_table :profile_lists do |t|
      t.text :description
      t.integer :section_type, null: false
      t.integer :acceptor_id
      t.boolean :accepted, default: false, null: false
      t.integer :profile_id, unique: true, null: false
      t.string :attachments
      t.timestamps
    end
  end
end

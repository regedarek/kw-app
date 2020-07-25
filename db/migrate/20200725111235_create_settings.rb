class CreateSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :settings do |t|
      t.string :name, null: false
      t.text :content
      t.string :back_url
      t.integer :content_type, null: false, default: 0
      t.timestamps
    end
  end
end

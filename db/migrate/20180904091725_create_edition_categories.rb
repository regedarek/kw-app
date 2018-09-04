class CreateEditionCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :edition_categories do |t|
      t.integer :edition_record_id, null: false
      t.string :name, null: false
      t.timestamps
    end
  end
end

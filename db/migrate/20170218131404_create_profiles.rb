class CreateProfiles < ActiveRecord::Migration[5.0]
  def change
    create_table :profiles do |t|
      t.integer :kw_id, null: false
      t.date :birth_date, null: false
      t.string :birth_place, null: false
      t.string :pesel, null: false
      t.string :city, null: false
      t.string :postal_code, null: false
      t.string :main_address, null: false
      t.string :optional_address
      t.text :recommended_by, array: true, default: []
      t.integer :acomplished_course, array: true, default: []
      t.boolean :main_discussion_group, default: false
      t.text :section, array: true, default: []
      t.timestamps
    end

    add_index :profiles, :kw_id, unique: true
  end
end

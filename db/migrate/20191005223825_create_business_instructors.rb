class CreateBusinessInstructors < ActiveRecord::Migration[5.2]
  def change
    create_table :business_instructors do |t|
      t.string :name
      t.integer :kw_id
      t.boolean :active, null: false, default: true
      t.string :description
      t.string :attachements
      t.timestamps
    end
  end
end

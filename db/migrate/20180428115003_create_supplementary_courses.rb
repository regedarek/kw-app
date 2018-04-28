class CreateSupplementaryCourses < ActiveRecord::Migration[5.0]
  def change
    create_table :supplementary_courses do |t|
      t.string :name
      t.string :place
      t.datetime :start_date
      t.datetime :end_date
      t.integer :organizator_id
      t.text :participants, default: [], array: true
      t.integer :price_kw
      t.integer :price_non_kw
      t.datetime :application_date
      t.boolean :accepted, default: false
      t.text :remarks
      t.timestamps
    end
  end
end

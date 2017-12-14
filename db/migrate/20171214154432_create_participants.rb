class CreateParticipants < ActiveRecord::Migration[5.0]
  def change
    create_table :participants do |t|
      t.string :full_name
      t.string :email, null: false
      t.string :phone
      t.string :prefered_time, default: [], array: true
      t.text :equipment, default: [], array: true
      t.string :height
      t.text :recommended_by, default: [], array: true
      t.integer :kw_id
      t.integer :course_id, null: false
      t.date :birth_date
      t.string :birth_place
      t.string :pre_cost
      t.timestamps
    end
  end
end

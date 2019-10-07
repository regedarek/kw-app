class CreateSnwApplies < ActiveRecord::Migration[5.2]
  def change
    create_table :snw_applies do |t|
      t.integer :kw_id, null: false
      t.string :cv, null: false
      t.string :skills
      t.string :courses
      t.boolean :avalanche, null: false, default: false
      t.date :avalanche_date
      t.boolean :first_aid, null: false, default: false
      t.string :attachments
      t.string :state, null: false, default: 'new'
      t.timestamps
    end
  end
end

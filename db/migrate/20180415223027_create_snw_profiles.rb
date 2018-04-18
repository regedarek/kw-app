class CreateSnwProfiles < ActiveRecord::Migration[5.0]
  def change
    create_table :snw_profiles do |t|
      t.string :question_1
      t.integer :question_2
      t.timestamps
    end
  end
end

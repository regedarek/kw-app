class G < ActiveRecord::Migration[5.2]
  def change
    create_table :club_meetings_ideas do |t|
      t.string :name, null: false, index: { unique: true }
      t.string :slug, null: false, index: { unique: true }
      t.references :user, foreign_key: true, null: false, index: true
      t.text :description
      t.timestamps
    end
  end
end

class CreateDbYearlyPrizeRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :yearly_prize_requests do |t|
      t.references :yearly_prize_edition, foreign_key: true, null: false
      t.references :user, foreign_key: true, null: false
      t.text :author_description
      t.integer :author_id, foreign_key: true, null: false
      t.text :prize_jury_description
      t.integer :likes_count, default: 0, null: false

      t.timestamps
    end

    add_index :yearly_prize_requests, :author_id
  end
end

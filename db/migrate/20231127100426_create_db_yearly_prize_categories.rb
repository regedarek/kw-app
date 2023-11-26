class CreateDbYearlyPrizeCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :yearly_prize_categories do |t|
      t.references :yearly_prize_edition, foreign_key: true, null: false
      t.text :description
      t.string :name, null: false

      t.timestamps
    end
  end
end

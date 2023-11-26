class CreateDbYearlyPrizeEditions < ActiveRecord::Migration[5.2]
  def change
    create_table :yearly_prize_editions do |t|
      t.integer :year, null: false
      t.string :name, null: false
      t.text :description

      t.timestamps
    end
  end
end

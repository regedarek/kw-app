class CreateYearlyFeesTable < ActiveRecord::Migration[5.0]
  def change
    create_table :yearly_fees do |t|
      t.string :year
      t.integer :cost, default: 100
    end
  end
end

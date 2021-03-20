class SettlementIncomes < ActiveRecord::Migration[5.2]
  def change
    create_table :settlement_incomes do |t|
      t.string :name
      t.string :description
      t.float :cost

      t.timestamps null: false
    end
  end
end

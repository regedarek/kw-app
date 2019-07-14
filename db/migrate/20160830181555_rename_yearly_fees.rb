class RenameYearlyFees < ActiveRecord::Migration[5.0]
  def change
    rename_table :yearly_fees, :membership_fees
    change_column :membership_fees, :cost, :integer, default: 100
  end
end

class RenameYearlyFees < ActiveRecord::Migration
  def change
    rename_table :yearly_fees, :membership_fees
    change_column :membership_fees, :cost, :integer, default: 100
  end
end

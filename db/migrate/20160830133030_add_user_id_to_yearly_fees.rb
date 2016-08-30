class AddUserIdToYearlyFees < ActiveRecord::Migration
  def change
    add_column :yearly_fees, :user_id, :integer
  end
end

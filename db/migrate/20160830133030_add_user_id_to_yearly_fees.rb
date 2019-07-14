class AddUserIdToYearlyFees < ActiveRecord::Migration[5.0]
  def change
    add_column :yearly_fees, :user_id, :integer
  end
end

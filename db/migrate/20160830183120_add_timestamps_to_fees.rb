class AddTimestampsToFees < ActiveRecord::Migration[5.0]
  def change
    add_column :membership_fees, :created_at, :datetime
    add_column :membership_fees, :updated_at, :datetime
  end
end

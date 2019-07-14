class AddPayedAtToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :payed_at, :datetime
  end
end

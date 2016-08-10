class AddPayedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :payed_at, :datetime
  end
end

class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :type
      t.integer :order_id
    end
  end
end

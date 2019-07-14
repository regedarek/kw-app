class CreateServices < ActiveRecord::Migration[5.0]
  def change
    create_table :services do |t|
      t.string :type
      t.integer :order_id
    end
  end
end

class TimestampCreateHearts < ActiveRecord::Migration[5.0]
  def change
    create_table :hearts do |t|
      t.belongs_to :mountain_route, index: true
      t.belongs_to :user, index: true
      t.timestamps null: false
    end
  end
end

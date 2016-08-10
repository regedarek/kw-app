class CreateValleyTable < ActiveRecord::Migration
  def change
    create_table :valleys do |t|
      t.string :name
    end
  end
end
